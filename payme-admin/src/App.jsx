import React, { useState, useEffect } from 'react';
import { supabase } from './supabaseClient';
import Sidebar from './components/Sidebar';
import StatCards from './components/StatCards';
import KycTab from './components/KycTab';
import AuditTab from './components/AuditTab';
import UsersTab from './components/UsersTab';
import KtpModal from './components/KtpModal';
import TopUpModal from './components/TopUpModal';
import ResetPinModal from './components/ResetPinModal';
import { RefreshCw, Bell, Shield, ArrowRight, Radio, PlusCircle, CreditCard, Sparkles } from 'lucide-react';
import confetti from 'canvas-confetti';
import './App.css';

export default function App() {
  const [selectedTab, setSelectedTab] = useState(0); // 0: Overview, 1: KYC, 2: Audit, 3: Users
  const [isLoading, setIsLoading] = useState(true);
  const [isProcessing, setIsProcessing] = useState(false);
  const [notification, setNotification] = useState(null);

  const [allUsers, setAllUsers] = useState([]);
  const [pendingKycUsers, setPendingKycUsers] = useState([]);
  const [allTransactions, setAllTransactions] = useState([]);
  const [totalBalance, setTotalBalance] = useState(0);

  // Modals state
  const [selectedUserKtp, setSelectedUserKtp] = useState(null);
  const [selectedUserTopUp, setSelectedUserTopUp] = useState(null);
  const [selectedUserResetPin, setSelectedUserResetPin] = useState(null);

  useEffect(() => {
    loadDashboardData();

    // Supabase Realtime WebSocket Listeners
    const channel = supabase
      .channel('payme-admin-realtime')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'users' },
        (payload) => {
          console.log('[Realtime] users table updated:', payload);
          loadDashboardData(false);
        }
      )
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'wallets' },
        (payload) => {
          console.log('[Realtime] wallets table updated:', payload);
          loadDashboardData(false);
        }
      )
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'transactions' },
        (payload) => {
          console.log('[Realtime] transactions table updated:', payload);
          loadDashboardData(false);
        }
      )
      .subscribe((status) => {
        console.log('[Realtime Subscription Status]:', status);
      });

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  const showNotification = (message, type = 'success') => {
    setNotification({ message, type });
    setTimeout(() => {
      setNotification(null);
    }, 4000);
  };

  const loadDashboardData = async (showLoadingSpinner = true) => {
    if (showLoadingSpinner) setIsLoading(true);
    try {
      // 1. Ambil data users
      const { data: usersData, error: usersError } = await supabase
        .from('users')
        .select('*')
        .order('created_at', { ascending: false });

      if (usersError) throw usersError;
      const usersList = usersData || [];

      // 2. Ambil data wallets
      const { data: walletsData } = await supabase
        .from('wallets')
        .select('*');

      const walletsList = walletsData || [];

      // Hitung total saldo
      let sumBalance = 0;
      for (const w of walletsList) {
        sumBalance += Number(w.balance || 0);
      }

      // Gabungkan wallet ke data user
      for (const u of usersList) {
        const matchWallet = walletsList.find((w) => w.user_id === u.id) || {};
        u.card_number = matchWallet.card_number || '-';
        u.balance = matchWallet.balance || 0;
      }

      // 3. Ambil data transaksi
      const { data: txData } = await supabase
        .from('transactions')
        .select('*')
        .order('created_at', { ascending: false });

      const txList = txData || [];

      // Calon KYC: unverified DAN memiliki foto KTP
      const pendingList = usersList.filter(
        (u) => !u.is_verified && u.ktp_picture && u.ktp_picture.trim() !== ''
      );

      setAllUsers(usersList);
      setPendingKycUsers(pendingList);
      setAllTransactions(txList);
      setTotalBalance(sumBalance);
    } catch (err) {
      console.error('Error fetching dashboard data:', err);
      showNotification('Gagal memuat data dari Supabase: ' + (err.message || err), 'danger');
    } finally {
      if (showLoadingSpinner) setIsLoading(false);
    }
  };

  // KYC Approval
  const handleApproveKyc = async (userId, userName) => {
    setIsProcessing(true);
    try {
      const { error } = await supabase
        .from('users')
        .update({ is_verified: true })
        .eq('id', userId);

      if (error) throw error;

      try {
        confetti({
          particleCount: 80,
          spread: 70,
          origin: { y: 0.6 }
        });
      } catch (_) {}

      showNotification(`Verifikasi KYC untuk ${userName} berhasil disetujui!`, 'success');
      setSelectedUserKtp(null);
      await loadDashboardData();
    } catch (err) {
      showNotification('Gagal verifikasi: ' + (err.message || err), 'danger');
    } finally {
      setIsProcessing(false);
    }
  };

  // KYC Rejection
  const handleRejectKyc = async (userId, userName) => {
    setIsProcessing(true);
    try {
      const { error } = await supabase
        .from('users')
        .update({ is_verified: false, ktp_picture: null })
        .eq('id', userId);

      if (error) throw error;

      showNotification(`Dokumen KTP ${userName} ditolak dan telah dihapus.`, 'warning');
      setSelectedUserKtp(null);
      await loadDashboardData();
    } catch (err) {
      showNotification('Gagal menolak: ' + (err.message || err), 'danger');
    } finally {
      setIsProcessing(false);
    }
  };

  // Manual Toggle KYC Status (dari Users Directory)
  const handleToggleVerification = async (userId, userName, newStatus) => {
    setIsProcessing(true);
    try {
      const { error } = await supabase
        .from('users')
        .update({ is_verified: newStatus })
        .eq('id', userId);

      if (error) throw error;

      showNotification(
        `Status verifikasi ${userName} diubah menjadi: ${newStatus ? 'VERIFIED' : 'UNVERIFIED'}`,
        'info'
      );
      await loadDashboardData();
    } catch (err) {
      showNotification('Gagal mengubah status: ' + (err.message || err), 'danger');
    } finally {
      setIsProcessing(false);
    }
  };

  // Top Up Saldo Manual oleh Admin
  const handleAdminTopUp = async (userId, userName, amount, note) => {
    setIsProcessing(true);
    try {
      // 1. Ambil data wallet
      const { data: walletData, error: walletErr } = await supabase
        .from('wallets')
        .select('*')
        .eq('user_id', userId)
        .maybeSingle();

      if (walletErr) throw walletErr;

      if (!walletData) {
        // Buat wallet jika belum ada
        const newCardNumber = '5322' + Math.floor(100000000000 + Math.random() * 900000000000);
        const { error: createWalletErr } = await supabase
          .from('wallets')
          .insert([
            {
              user_id: userId,
              balance: Number(amount),
              card_number: newCardNumber,
              created_at: new Date().toISOString()
            }
          ]);
        if (createWalletErr) throw createWalletErr;
      } else {
        const currentBalance = Number(walletData.balance || 0);
        const newBalance = currentBalance + Number(amount);

        const { error: updateErr } = await supabase
          .from('wallets')
          .update({ balance: newBalance })
          .eq('user_id', userId);

        if (updateErr) throw updateErr;
      }

      // 2. Buat log transaksi di tabel transactions
      const { error: txErr } = await supabase
        .from('transactions')
        .insert([
          {
            user_id: userId,
            title: note || 'Top Up Manual oleh Admin',
            amount: Number(amount),
            transaction_type_code: 'TOP_UP',
            status: 'success',
            created_at: new Date().toISOString()
          }
        ]);

      if (txErr) {
        console.warn('Gagal mencatat log transaksi:', txErr);
      }

      try {
        confetti({
          particleCount: 70,
          spread: 60,
          origin: { y: 0.6 }
        });
      } catch (_) {}

      showNotification(`Berhasil menambahkan saldo Rp ${Number(amount).toLocaleString('id-ID')} untuk ${userName}!`, 'success');
      setSelectedUserTopUp(null);
      await loadDashboardData();
    } catch (err) {
      console.error('Topup error:', err);
      showNotification('Gagal top up saldo: ' + (err.message || err), 'danger');
    } finally {
      setIsProcessing(false);
    }
  };

  // Reset PIN Transaksi Akun oleh Admin
  const handleAdminResetPin = async (userId, userName, newPin) => {
    setIsProcessing(true);
    try {
      const { error } = await supabase
        .from('users')
        .update({ pin: newPin })
        .eq('id', userId);

      if (error) throw error;

      showNotification(`PIN transaksi untuk ${userName} berhasil direset menjadi ${newPin}`, 'success');
      setSelectedUserResetPin(null);
      await loadDashboardData();
    } catch (err) {
      console.error('Reset PIN error:', err);
      showNotification('Gagal reset PIN: ' + (err.message || err), 'danger');
    } finally {
      setIsProcessing(false);
    }
  };

  // Hapus Pengguna oleh Admin
  const handleAdminDeleteUser = async (userId, userName) => {
    const confirmDelete = window.confirm(
      `Apakah Anda yakin ingin menghapus akun "${userName}"?\n\nSeluruh mutasi, saldo dompet, dan riwayat akan dihapus secara permanen.`
    );
    if (!confirmDelete) return;

    setIsProcessing(true);
    try {
      // 1. Hapus transactions
      await supabase.from('transactions').delete().eq('user_id', userId);
      // 2. Hapus wallets
      await supabase.from('wallets').delete().eq('user_id', userId);
      // 3. Hapus user
      const { error } = await supabase.from('users').delete().eq('id', userId);

      if (error) throw error;

      showNotification(`Pengguna ${userName} telah dihapus dari sistem.`, 'warning');
      await loadDashboardData();
    } catch (err) {
      console.error('Delete user error:', err);
      showNotification('Gagal menghapus pengguna: ' + (err.message || err), 'danger');
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="app-container">
      {/* Toast Notification */}
      {notification && (
        <div 
          className={`badge badge-${notification.type} fade-in`}
          style={{
            position: 'fixed',
            top: '24px',
            right: '24px',
            zIndex: 9999,
            padding: '12px 20px',
            fontSize: '14px',
            boxShadow: '0 10px 25px rgba(0,0,0,0.5)',
            backdropFilter: 'blur(10px)'
          }}
        >
          {notification.message}
        </div>
      )}

      {/* Sidebar */}
      <Sidebar 
        selectedTab={selectedTab} 
        onSelectTab={setSelectedTab}
        pendingCount={pendingKycUsers.length}
        totalUsersCount={allUsers.length}
      />

      {/* Main Content Area */}
      <main className="main-content">
        <header className="top-header">
          <div className="header-title">
            <h2>
              {selectedTab === 0 && 'Financial Overview & KPI'}
              {selectedTab === 1 && 'Pusat Verifikasi KYC Identitas'}
              {selectedTab === 2 && 'Audit Mutasi Saldo & Transaksi'}
              {selectedTab === 3 && 'Direktori & Manajemen Pengguna'}
            </h2>
            <p>
              Payme Fintech Central Back-Office System • Supabase PostgreSQL Environment
            </p>
          </div>

          <div className="header-actions" style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            {/* Realtime Indicator */}
            <div 
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                padding: '6px 12px',
                borderRadius: '20px',
                background: 'rgba(16, 185, 129, 0.1)',
                border: '1px solid rgba(16, 185, 129, 0.25)',
                fontSize: '12px',
                color: '#34D399',
                fontWeight: 600
              }}
            >
              <Radio size={14} className="pulse-anim" />
              <span>Real-Time Sync</span>
            </div>

            <button 
              className="btn btn-secondary btn-sm"
              onClick={() => loadDashboardData(true)}
              disabled={isLoading}
              title="Refresh Data"
            >
              <RefreshCw size={15} className={isLoading ? 'rotate-anim' : ''} />
              <span>{isLoading ? 'Menyinkronkan...' : 'Refresh Data'}</span>
            </button>
          </div>
        </header>

        <div className="content-body">
          {/* Stat Cards - Selalu ditampilkan di atas */}
          <StatCards 
            totalUsers={allUsers.length}
            pendingKyc={pendingKycUsers.length}
            totalBalance={totalBalance}
            totalTransactions={allTransactions.length}
            onCardClick={setSelectedTab}
          />

          {/* Konten Tab */}
          {selectedTab === 0 && (
            <div className="fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '28px' }}>
              {/* Antrean KYC Terkini */}
              <div className="glass-card" style={{ padding: '24px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '18px' }}>
                  <div>
                    <h3 style={{ fontSize: '17px', fontWeight: 600 }}>Antrean Verifikasi KTP Terkini</h3>
                    <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                      Tinjau dan setujui pengguna yang baru mengunggah KTP
                    </p>
                  </div>
                  <button 
                    className="btn btn-secondary btn-sm"
                    onClick={() => setSelectedTab(1)}
                  >
                    Buka Tab KYC ({pendingKycUsers.length})
                    <ArrowRight size={14} />
                  </button>
                </div>

                <KycTab 
                  pendingUsers={pendingKycUsers.slice(0, 3)}
                  onViewKtp={setSelectedUserKtp}
                  onApprove={handleApproveKyc}
                  onReject={handleRejectKyc}
                  isProcessing={isProcessing}
                />
              </div>

              {/* Sekilas Pengguna & Aksi Cepat */}
              <div className="glass-card" style={{ padding: '24px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '18px' }}>
                  <div>
                    <h3 style={{ fontSize: '17px', fontWeight: 600 }}>Aksi Cepat Nasabah Terdaftar</h3>
                    <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                      Tambah saldo instan atau kelola akun langsung dari dashboard
                    </p>
                  </div>
                  <button 
                    className="btn btn-secondary btn-sm"
                    onClick={() => setSelectedTab(3)}
                  >
                    Lihat Semua ({allUsers.length})
                    <ArrowRight size={14} />
                  </button>
                </div>

                <UsersTab 
                  users={allUsers.slice(0, 4)}
                  onViewKtp={setSelectedUserKtp}
                  onToggleVerification={handleToggleVerification}
                  onOpenTopUp={setSelectedUserTopUp}
                  onOpenResetPin={setSelectedUserResetPin}
                  onDeleteUser={handleAdminDeleteUser}
                  isProcessing={isProcessing}
                />
              </div>

              {/* Sekilas Transaksi Terkini */}
              <div className="glass-card" style={{ padding: '24px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '18px' }}>
                  <div>
                    <h3 style={{ fontSize: '17px', fontWeight: 600 }}>Log Transaksi Terbaru</h3>
                    <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                      5 mutasi finansial terkini di sistem
                    </p>
                  </div>
                  <button 
                    className="btn btn-secondary btn-sm"
                    onClick={() => setSelectedTab(2)}
                  >
                    Buka Semua Log Transaksi
                    <ArrowRight size={14} />
                  </button>
                </div>

                <AuditTab transactions={allTransactions.slice(0, 5)} />
              </div>
            </div>
          )}

          {selectedTab === 1 && (
            <KycTab 
              pendingUsers={pendingKycUsers}
              onViewKtp={setSelectedUserKtp}
              onApprove={handleApproveKyc}
              onReject={handleRejectKyc}
              isProcessing={isProcessing}
            />
          )}

          {selectedTab === 2 && (
            <AuditTab transactions={allTransactions} />
          )}

          {selectedTab === 3 && (
            <UsersTab 
              users={allUsers}
              onViewKtp={setSelectedUserKtp}
              onToggleVerification={handleToggleVerification}
              onOpenTopUp={setSelectedUserTopUp}
              onOpenResetPin={setSelectedUserResetPin}
              onDeleteUser={handleAdminDeleteUser}
              isProcessing={isProcessing}
            />
          )}
        </div>
      </main>

      {/* Modal Preview KTP */}
      {selectedUserKtp && (
        <KtpModal 
          user={selectedUserKtp}
          onClose={() => setSelectedUserKtp(null)}
          onApprove={handleApproveKyc}
          onReject={handleRejectKyc}
          isProcessing={isProcessing}
        />
      )}

      {/* Modal Top Up Saldo Manual */}
      {selectedUserTopUp && (
        <TopUpModal 
          user={selectedUserTopUp}
          onClose={() => setSelectedUserTopUp(null)}
          onSubmit={handleAdminTopUp}
          isProcessing={isProcessing}
        />
      )}

      {/* Modal Reset PIN Transaksi */}
      {selectedUserResetPin && (
        <ResetPinModal 
          user={selectedUserResetPin}
          onClose={() => setSelectedUserResetPin(null)}
          onSubmit={handleAdminResetPin}
          isProcessing={isProcessing}
        />
      )}
    </div>
  );
}


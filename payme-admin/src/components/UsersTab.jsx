import React, { useState } from 'react';
import { Search, ShieldCheck, ShieldAlert, CreditCard, UserX, UserCheck, Eye, PlusCircle, KeyRound, Trash2 } from 'lucide-react';

export default function UsersTab({ 
  users, 
  onViewKtp, 
  onToggleVerification, 
  onOpenTopUp,
  onOpenResetPin,
  onDeleteUser,
  isProcessing 
}) {
  const [searchTerm, setSearchTerm] = useState('');

  const formatRupiah = (val) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0
    }).format(val || 0);
  };

  const filtered = (users || []).filter((u) => {
    const q = searchTerm.toLowerCase();
    return (
      (u.name || '').toLowerCase().includes(q) ||
      (u.username || '').toLowerCase().includes(q) ||
      (u.email || '').toLowerCase().includes(q) ||
      (u.card_number || '').toLowerCase().includes(q)
    );
  });

  return (
    <div className="fade-in">
      <div className="section-toolbar">
        <div>
          <h3 style={{ fontSize: '18px', fontWeight: 600 }}>Direktori Semua Pengguna ({users?.length || 0})</h3>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Data seluruh akun nasabah yang terdaftar di database Payme beserta nomor kartu dan saldo dompet.
          </p>
        </div>

        <div className="search-box">
          <Search size={16} color="var(--text-subtle)" />
          <input 
            type="text" 
            placeholder="Cari nama, email, username, kartu..." 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      <div className="table-container">
        <table className="modern-table">
          <thead>
            <tr>
              <th>Pengguna</th>
              <th>Nomor Kartu Virtual</th>
              <th>Saldo Dompet</th>
              <th>Status KYC</th>
              <th style={{ textAlign: 'right' }}>Aksi Manajemen</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr>
                <td colSpan="5">
                  <div className="empty-state">
                    <UserX size={32} color="var(--text-subtle)" />
                    <h4 style={{ marginTop: '12px' }}>Pengguna Tidak Ditemukan</h4>
                    <p>Tidak ada pengguna yang cocok dengan kata kunci "{searchTerm}".</p>
                  </div>
                </td>
              </tr>
            ) : (
              filtered.map((user) => (
                <tr key={user.id}>
                  <td>
                    <div className="user-cell">
                      {user.profile_picture ? (
                        <img 
                          src={user.profile_picture} 
                          alt={user.name} 
                          className="user-avatar"
                          onError={(e) => {
                            e.target.onerror = null;
                            e.target.src = 'https://placehold.co/100x100/1E293B/FFF?text=' + (user.name?.[0] || 'U');
                          }}
                        />
                      ) : (
                        <div className="user-avatar-fallback">
                          {user.name ? user.name[0].toUpperCase() : 'U'}
                        </div>
                      )}
                      <div className="user-info">
                        <div className="name" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                          {user.name || 'Nama Belum Diatur'}
                          {user.is_verified && (
                            <ShieldCheck size={16} color="#10B981" title="Verified KYC" />
                          )}
                        </div>
                        <div className="sub">@{user.username || 'user'} • {user.email}</div>
                      </div>
                    </div>
                  </td>

                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <CreditCard size={15} color="#38BDF8" />
                      <span style={{ fontFamily: 'monospace', fontSize: '13px', color: '#E2E8F0' }}>
                        {user.card_number || '-'}
                      </span>
                    </div>
                  </td>

                  <td>
                    <span 
                      style={{ 
                        fontWeight: 700, 
                        fontFamily: 'var(--font-display)',
                        color: '#34D399',
                        fontSize: '15px'
                      }}
                    >
                      {formatRupiah(user.balance)}
                    </span>
                  </td>

                  <td>
                    {user.is_verified ? (
                      <span className="badge badge-success">
                        <ShieldCheck size={13} />
                        Verified
                      </span>
                    ) : (
                      <span className="badge badge-warning">
                        <ShieldAlert size={13} />
                        Unverified
                      </span>
                    )}
                  </td>

                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: '8px', flexWrap: 'wrap' }}>
                      {/* Top Up Saldo Manual */}
                      <button 
                        className="btn btn-success btn-sm"
                        onClick={() => onOpenTopUp && onOpenTopUp(user)}
                        title="Tambah Saldo Manual"
                        disabled={isProcessing}
                      >
                        <PlusCircle size={14} />
                        + Saldo
                      </button>

                      {/* Lihat KTP jika ada */}
                      {user.ktp_picture && (
                        <button 
                          className="btn btn-secondary btn-sm"
                          onClick={() => onViewKtp(user)}
                          title="Lihat Dokumen KTP"
                        >
                          <Eye size={14} />
                          KTP
                        </button>
                      )}

                      {/* Toggle Verifikasi */}
                      <button 
                        className={`btn btn-sm ${user.is_verified ? 'btn-secondary' : 'btn-primary'}`}
                        onClick={() => onToggleVerification(user.id, user.name, !user.is_verified)}
                        disabled={isProcessing}
                        title={user.is_verified ? 'Batalkan status verifikasi' : 'Setujui verifikasi user'}
                      >
                        {user.is_verified ? <UserX size={14} /> : <UserCheck size={14} />}
                        {user.is_verified ? 'Batal Verify' : 'Verifikasi'}
                      </button>

                      {/* Reset PIN */}
                      <button 
                        className="btn btn-secondary btn-sm"
                        onClick={() => onOpenResetPin && onOpenResetPin(user)}
                        title="Reset PIN Transaksi"
                        disabled={isProcessing}
                      >
                        <KeyRound size={14} color="#F59E0B" />
                        PIN
                      </button>

                      {/* Hapus User */}
                      <button 
                        className="btn btn-danger btn-sm"
                        onClick={() => onDeleteUser && onDeleteUser(user.id, user.name)}
                        title="Hapus Pengguna"
                        disabled={isProcessing}
                      >
                        <Trash2 size={14} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

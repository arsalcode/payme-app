import React, { useState } from 'react';
import { Search, ArrowDownLeft, ArrowUpRight, Filter, Receipt, CheckCircle2, Clock } from 'lucide-react';

export default function AuditTab({ transactions = [] }) {
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('ALL');

  const formatRupiah = (val) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0
    }).format(val || 0);
  };

  // Deteksi kategori transaksi berdasarkan judul & kode tipe
  const getTransactionCategory = (tx) => {
    const title = (tx.title || '').toLowerCase();
    const code = (tx.transaction_type_code || tx.type || '').toUpperCase();

    if (
      title.includes('top up') || 
      title.includes('topup') || 
      title.includes('cashback') || 
      code.includes('TOP') || 
      code.includes('IN')
    ) {
      return 'TOPUP';
    }

    if (
      title.includes('transfer') || 
      title.includes('kirim') || 
      title.includes('@') || 
      code.includes('TRANSFER')
    ) {
      return 'TRANSFER';
    }

    if (
      title.includes('tarik') || 
      title.includes('withdraw') || 
      title.includes('atm') || 
      code.includes('WITH')
    ) {
      return 'WITHDRAW';
    }

    return 'PAYMENT';
  };

  // Deteksi apakah uang masuk (+) atau uang keluar (-)
  const isTransactionIncome = (tx) => {
    const cat = getTransactionCategory(tx);
    if (cat === 'TOPUP') return true;
    const title = (tx.title || '').toLowerCase();
    if (title.includes('terima') || title.includes('cashback') || title.includes('reward')) {
      return true;
    }
    return false;
  };

  // Hitung jumlah untuk masing-masing filter
  const topupCount = transactions.filter((t) => getTransactionCategory(t) === 'TOPUP').length;
  const transferCount = transactions.filter((t) => getTransactionCategory(t) === 'TRANSFER').length;
  const withdrawCount = transactions.filter((t) => getTransactionCategory(t) === 'WITHDRAW').length;
  const paymentCount = transactions.filter((t) => getTransactionCategory(t) === 'PAYMENT').length;

  const filtered = (transactions || []).filter((tx) => {
    const q = searchTerm.toLowerCase();
    const matchesSearch = 
      (tx.title || '').toLowerCase().includes(q) ||
      (tx.user_id || '').toLowerCase().includes(q) ||
      (tx.transaction_type_code || tx.type || '').toLowerCase().includes(q);

    if (!matchesSearch) return false;

    const cat = getTransactionCategory(tx);
    if (typeFilter === 'TOPUP') return cat === 'TOPUP';
    if (typeFilter === 'TRANSFER') return cat === 'TRANSFER';
    if (typeFilter === 'WITHDRAW') return cat === 'WITHDRAW';
    if (typeFilter === 'PAYMENT') return cat === 'PAYMENT';

    return true;
  });

  return (
    <div className="fade-in">
      <div className="section-toolbar">
        <div>
          <h3 style={{ fontSize: '18px', fontWeight: 600 }}>Audit Mutasi Keuangan</h3>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Log transaksi real-time seluruh aktivitas perpindahan saldo di ekosistem Payme.
          </p>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', flexWrap: 'wrap' }}>
          <div className="search-box">
            <Search size={16} color="var(--text-subtle)" />
            <input 
              type="text" 
              placeholder="Cari transaksi / user ID..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          <div className="filter-group">
            <button 
              className={`filter-btn ${typeFilter === 'ALL' ? 'active' : ''}`}
              onClick={() => setTypeFilter('ALL')}
            >
              Semua ({transactions?.length || 0})
            </button>
            <button 
              className={`filter-btn ${typeFilter === 'TOPUP' ? 'active' : ''}`}
              onClick={() => setTypeFilter('TOPUP')}
            >
              Top Up ({topupCount})
            </button>
            <button 
              className={`filter-btn ${typeFilter === 'TRANSFER' ? 'active' : ''}`}
              onClick={() => setTypeFilter('TRANSFER')}
            >
              Transfer ({transferCount})
            </button>
            <button 
              className={`filter-btn ${typeFilter === 'WITHDRAW' ? 'active' : ''}`}
              onClick={() => setTypeFilter('WITHDRAW')}
            >
              Tarik Tunai ({withdrawCount})
            </button>
            {paymentCount > 0 && (
              <button 
                className={`filter-btn ${typeFilter === 'PAYMENT' ? 'active' : ''}`}
                onClick={() => setTypeFilter('PAYMENT')}
              >
                Paket & Layanan ({paymentCount})
              </button>
            )}
          </div>
        </div>
      </div>

      <div className="table-container">
        <table className="modern-table">
          <thead>
            <tr>
              <th>Tipe & Judul Transaksi</th>
              <th>User ID</th>
              <th>Nominal</th>
              <th>Status</th>
              <th>Tanggal & Waktu</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr>
                <td colSpan="5">
                  <div className="empty-state">
                    <Receipt size={32} color="var(--text-subtle)" />
                    <h4 style={{ marginTop: '12px' }}>Tidak Ada Data Transaksi</h4>
                    <p>Belum ada riwayat transaksi yang cocok dengan filter "{typeFilter}".</p>
                  </div>
                </td>
              </tr>
            ) : (
              filtered.map((tx, idx) => {
                const isPositive = isTransactionIncome(tx);
                const cat = getTransactionCategory(tx);
                const categoryLabel = 
                  cat === 'TOPUP' ? 'TOP UP' :
                  cat === 'TRANSFER' ? 'TRANSFER' :
                  cat === 'WITHDRAW' ? 'TARIK TUNAI' : 'PEMBAYARAN';

                return (
                  <tr key={tx.id || idx}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <div 
                          className="stat-icon-wrapper"
                          style={{
                            width: '36px',
                            height: '36px',
                            background: isPositive ? 'rgba(16, 185, 129, 0.12)' : 'rgba(244, 63, 94, 0.12)',
                            color: isPositive ? '#34D399' : '#FB7185',
                            border: 'none'
                          }}
                        >
                          {isPositive ? <ArrowDownLeft size={18} /> : <ArrowUpRight size={18} />}
                        </div>
                        <div>
                          <div style={{ fontWeight: 600, color: 'var(--text-main)' }}>
                            {tx.title || 'Transaksi Payme'}
                          </div>
                          <div style={{ fontSize: '11px', color: 'var(--text-subtle)', textTransform: 'uppercase' }}>
                            Kategori: {categoryLabel}
                          </div>
                        </div>
                      </div>
                    </td>

                    <td>
                      <span style={{ fontFamily: 'monospace', fontSize: '12px', color: 'var(--text-subtle)' }}>
                        {tx.user_id ? tx.user_id.substring(0, 16) + '...' : '-'}
                      </span>
                    </td>

                    <td>
                      <span 
                        style={{ 
                          fontWeight: 700, 
                          fontFamily: 'var(--font-display)',
                          fontSize: '15px',
                          color: isPositive ? '#34D399' : '#F87171' 
                        }}
                      >
                        {isPositive ? '+' : '-'} {formatRupiah(Math.abs(tx.amount || 0))}
                      </span>
                    </td>

                    <td>
                      <span className="badge badge-success">
                        <CheckCircle2 size={12} />
                        {tx.status || 'SUCCESS'}
                      </span>
                    </td>

                    <td style={{ color: 'var(--text-muted)', fontSize: '13px' }}>
                      {tx.created_at ? new Date(tx.created_at).toLocaleString('id-ID', {
                        day: 'numeric',
                        month: 'short',
                        year: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit'
                      }) : '-'}
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}


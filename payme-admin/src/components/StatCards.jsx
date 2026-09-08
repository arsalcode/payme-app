import React from 'react';
import { Users, Clock, Wallet, ArrowLeftRight } from 'lucide-react';

export default function StatCards({ totalUsers, pendingKyc, totalBalance, totalTransactions, onCardClick }) {
  const formatRupiah = (val) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0
    }).format(val || 0);
  };

  return (
    <div className="stats-grid">
      <div 
        className="glass-card stat-card" 
        style={{ '--accent-gradient': 'linear-gradient(90deg, #06B6D4, #3B82F6)', cursor: 'pointer' }}
        onClick={() => onCardClick && onCardClick(3)}
      >
        <div className="stat-header">
          <span className="stat-label">Total Pengguna</span>
          <div className="stat-icon-wrapper" style={{ color: '#06B6D4' }}>
            <Users size={20} />
          </div>
        </div>
        <div className="stat-value">{totalUsers}</div>
        <div className="stat-sub">
          <span style={{ color: '#10B981', fontWeight: 600 }}>● Terdaftar</span> di database Payme
        </div>
      </div>

      <div 
        className="glass-card stat-card" 
        style={{ '--accent-gradient': 'linear-gradient(90deg, #F59E0B, #EF4444)', cursor: 'pointer' }}
        onClick={() => onCardClick && onCardClick(1)}
      >
        <div className="stat-header">
          <span className="stat-label">Antrean KYC</span>
          <div className="stat-icon-wrapper" style={{ color: '#F59E0B' }}>
            <Clock size={20} />
          </div>
        </div>
        <div className="stat-value" style={{ color: pendingKyc > 0 ? '#FBBF24' : 'var(--text-main)' }}>
          {pendingKyc}
        </div>
        <div className="stat-sub">
          {pendingKyc > 0 ? (
            <span style={{ color: '#F87171', fontWeight: 600 }}>Perlu ditinjau segera</span>
          ) : (
            <span style={{ color: '#34D399', fontWeight: 600 }}>Semua dokumen tuntas</span>
          )}
        </div>
      </div>

      <div 
        className="glass-card stat-card" 
        style={{ '--accent-gradient': 'linear-gradient(90deg, #10B981, #059669)' }}
      >
        <div className="stat-header">
          <span className="stat-label">Total Saldo Beredar</span>
          <div className="stat-icon-wrapper" style={{ color: '#10B981' }}>
            <Wallet size={20} />
          </div>
        </div>
        <div className="stat-value" style={{ fontSize: '24px', color: '#34D399' }}>
          {formatRupiah(totalBalance)}
        </div>
        <div className="stat-sub">
          Total likuiditas saldo di semua dompet
        </div>
      </div>

      <div 
        className="glass-card stat-card" 
        style={{ '--accent-gradient': 'linear-gradient(90deg, #8B5CF6, #5142E6)', cursor: 'pointer' }}
        onClick={() => onCardClick && onCardClick(2)}
      >
        <div className="stat-header">
          <span className="stat-label">Total Transaksi</span>
          <div className="stat-icon-wrapper" style={{ color: '#8B5CF6' }}>
            <ArrowLeftRight size={20} />
          </div>
        </div>
        <div className="stat-value">{totalTransactions}</div>
        <div className="stat-sub">
          Log transaksi audit keuangan
        </div>
      </div>
    </div>
  );
}

import React from 'react';
import { 
  ShieldCheck, 
  ReceiptText, 
  Users, 
  LayoutDashboard, 
  CheckCircle2, 
  ExternalLink 
} from 'lucide-react';

export default function Sidebar({ selectedTab, onSelectTab, pendingCount, totalUsersCount }) {
  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <div className="sidebar-logo">P</div>
        <div className="sidebar-title">
          <h1>Payme Admin</h1>
          <span>CENTRAL BACK-OFFICE</span>
        </div>
      </div>

      <nav className="sidebar-nav">
        <div className="nav-section-title">Menu Utama</div>

        <button 
          className={`nav-item ${selectedTab === 0 ? 'active' : ''}`}
          onClick={() => onSelectTab(0)}
        >
          <div className="nav-item-content">
            <LayoutDashboard size={18} />
            <span>Financial Overview</span>
          </div>
        </button>

        <button 
          className={`nav-item ${selectedTab === 1 ? 'active' : ''}`}
          onClick={() => onSelectTab(1)}
        >
          <div className="nav-item-content">
            <ShieldCheck size={18} />
            <span>Verifikasi KYC</span>
          </div>
          {pendingCount > 0 && (
            <span className="nav-badge">{pendingCount}</span>
          )}
        </button>

        <button 
          className={`nav-item ${selectedTab === 2 ? 'active' : ''}`}
          onClick={() => onSelectTab(2)}
        >
          <div className="nav-item-content">
            <ReceiptText size={18} />
            <span>Audit Mutasi</span>
          </div>
        </button>

        <button 
          className={`nav-item ${selectedTab === 3 ? 'active' : ''}`}
          onClick={() => onSelectTab(3)}
        >
          <div className="nav-item-content">
            <Users size={18} />
            <span>Semua User</span>
          </div>
          {totalUsersCount > 0 && (
            <span className="badge badge-info" style={{ padding: '2px 8px', fontSize: '11px' }}>
              {totalUsersCount}
            </span>
          )}
        </button>
      </nav>

      <div className="sidebar-footer">
        <div className="connection-status">
          <div className="status-dot"></div>
          <div>
            <div style={{ fontWeight: 600, color: 'var(--text-main)' }}>Supabase Cloud</div>
            <div style={{ fontSize: '11px', color: 'var(--text-subtle)' }}>Status: Terhubung & Aktif</div>
          </div>
        </div>
      </div>
    </aside>
  );
}

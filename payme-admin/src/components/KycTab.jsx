import React from 'react';
import { ShieldCheck, Eye, Check, X, ShieldAlert, Sparkles } from 'lucide-react';

export default function KycTab({ 
  pendingUsers, 
  onViewKtp, 
  onApprove, 
  onReject, 
  isProcessing 
}) {
  if (!pendingUsers || pendingUsers.length === 0) {
    return (
      <div className="glass-card empty-state fade-in">
        <div className="empty-state-icon">
          <Sparkles size={32} color="#10B981" />
        </div>
        <h4>Semua Antrean KYC Telah Tuntas!</h4>
        <p>Tidak ada pengguna yang sedang menunggu persetujuan identitas KTP saat ini.</p>
      </div>
    );
  }

  return (
    <div className="fade-in">
      <div className="section-toolbar">
        <div>
          <h3 style={{ fontSize: '18px', fontWeight: 600 }}>
            Antrean Verifikasi Dokumen KTP ({pendingUsers.length})
          </h3>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Periksa keabsahan foto KTP calon nasabah sebelum menyetujui akses akun verified.
          </p>
        </div>
      </div>

      <div className="kyc-grid">
        {pendingUsers.map((user) => (
          <div key={user.id} className="glass-card kyc-card">
            <div className="kyc-image-preview" onClick={() => onViewKtp(user)}>
              <img 
                src={user.ktp_picture} 
                alt={`KTP ${user.name}`} 
                onError={(e) => {
                  e.target.onerror = null;
                  e.target.src = 'https://placehold.co/400x250/141926/94A3B8?text=Foto+KTP';
                }}
              />
              <div className="kyc-image-overlay">
                <Eye size={18} />
                <span>Klik untuk Zoom</span>
              </div>
            </div>

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
                <div className="name">{user.name || 'Nama Belum Diisi'}</div>
                <div className="sub">@{user.username || 'user'} • {user.email}</div>
              </div>
            </div>

            <div className="kyc-details">
              <div className="kyc-row">
                <span>Tanggal Daftar:</span>
                <span>
                  {user.created_at ? new Date(user.created_at).toLocaleDateString('id-ID', {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric'
                  }) : '-'}
                </span>
              </div>
              <div className="kyc-row">
                <span>Status Akun:</span>
                <span className="badge badge-warning">Menunggu Review</span>
              </div>
            </div>

            <div className="kyc-actions">
              <button 
                className="btn btn-danger btn-sm" 
                onClick={() => onReject(user.id, user.name)}
                disabled={isProcessing}
              >
                <X size={15} />
                Tolak
              </button>
              <button 
                className="btn btn-success btn-sm" 
                onClick={() => onApprove(user.id, user.name)}
                disabled={isProcessing}
              >
                <Check size={15} />
                Approve
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

import React from 'react';
import { X, CheckCircle, AlertTriangle, ExternalLink, ShieldCheck } from 'lucide-react';
import confetti from 'canvas-confetti';

export default function KtpModal({ user, onClose, onApprove, onReject, isProcessing }) {
  if (!user) return null;

  const handleApprove = () => {
    confetti({
      particleCount: 80,
      spread: 70,
      origin: { y: 0.6 }
    });
    onApprove(user.id, user.name);
  };

  return (
    <div className="modal-backdrop fade-in" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <ShieldCheck color="#5142E6" size={22} />
            <h3>Review Dokumen KTP: {user.name}</h3>
          </div>
          <button className="modal-close" onClick={onClose}>
            <X size={20} />
          </button>
        </div>

        <div className="modal-body">
          <div className="modal-image-wrapper">
            {user.ktp_picture ? (
              <img 
                src={user.ktp_picture} 
                alt={`KTP ${user.name}`} 
                onError={(e) => {
                  e.target.onerror = null;
                  e.target.src = 'https://placehold.co/600x380/141926/94A3B8?text=Gagal+Memuat+Gambar+KTP';
                }}
              />
            ) : (
              <div style={{ color: 'var(--text-subtle)', padding: '40px' }}>
                Pengguna belum mengunggah dokumen KTP.
              </div>
            )}
          </div>

          <div className="kyc-details">
            <div className="kyc-row">
              <span>Nama Lengkap:</span>
              <span>{user.name || '-'}</span>
            </div>
            <div className="kyc-row">
              <span>Username:</span>
              <span>@{user.username || '-'}</span>
            </div>
            <div className="kyc-row">
              <span>Email:</span>
              <span>{user.email || '-'}</span>
            </div>
            <div className="kyc-row">
              <span>User ID (UUID):</span>
              <span style={{ fontFamily: 'monospace', fontSize: '12px' }}>{user.id}</span>
            </div>
            <div className="kyc-row">
              <span>Nomor Kartu Debit:</span>
              <span style={{ fontFamily: 'monospace', color: '#38BDF8' }}>
                {user.card_number || '-'}
              </span>
            </div>
          </div>
        </div>

        <div className="modal-footer">
          <button className="btn btn-secondary" onClick={onClose} disabled={isProcessing}>
            Batal
          </button>
          <button 
            className="btn btn-danger" 
            onClick={() => onReject(user.id, user.name)}
            disabled={isProcessing}
          >
            <AlertTriangle size={16} />
            Tolak Dokumen
          </button>
          <button 
            className="btn btn-success" 
            onClick={handleApprove}
            disabled={isProcessing}
          >
            <CheckCircle size={16} />
            Approve & Verifikasi
          </button>
        </div>
      </div>
    </div>
  );
}

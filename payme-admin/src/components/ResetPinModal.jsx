import React, { useState } from 'react';
import { X, KeyRound, Check } from 'lucide-react';

export default function ResetPinModal({ user, onClose, onSubmit, isProcessing }) {
  const [newPin, setNewPin] = useState('123456');

  if (!user) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (newPin.trim().length !== 6) return;
    onSubmit(user.id, user.name, newPin.trim());
  };

  return (
    <div className="modal-backdrop fade-in" onClick={onClose}>
      <div className="modal-content" style={{ maxWidth: '420px' }} onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <KeyRound color="#F59E0B" size={22} />
            <h3>Reset PIN: {user.name}</h3>
          </div>
          <button className="modal-close" onClick={onClose}>
            <X size={20} />
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="modal-body">
            <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
              Setel ulang PIN transaksi pengguna jika pengguna lupa PIN akunnya.
            </p>

            <div>
              <label style={{ fontSize: '13px', color: 'var(--text-subtle)', fontWeight: 600, display: 'block', marginBottom: '8px' }}>
                PIN BARU (6 DIGIT ANGKA)
              </label>
              <input
                type="text"
                maxLength={6}
                value={newPin}
                onChange={(e) => setNewPin(e.target.value.replace(/\D/g, ''))}
                style={{
                  width: '100%',
                  padding: '12px 16px',
                  background: 'var(--bg-main)',
                  border: '1px solid var(--border-color)',
                  borderRadius: 'var(--radius-sm)',
                  color: '#FBBF24',
                  fontSize: '22px',
                  fontWeight: 700,
                  letterSpacing: '8px',
                  textAlign: 'center',
                  outline: 'none',
                }}
              />
            </div>
          </div>

          <div className="modal-footer">
            <button type="button" className="btn btn-secondary" onClick={onClose} disabled={isProcessing}>
              Batal
            </button>
            <button type="submit" className="btn btn-primary" disabled={isProcessing || newPin.length !== 6}>
              <Check size={16} />
              {isProcessing ? 'Menyimpan...' : 'Reset PIN'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

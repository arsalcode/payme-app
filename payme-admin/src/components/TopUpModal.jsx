import React, { useState } from 'react';
import { X, Wallet, PlusCircle } from 'lucide-react';

export default function TopUpModal({ user, onClose, onSubmit, isProcessing }) {
  const [amount, setAmount] = useState(100000);
  const [note, setNote] = useState('Top Up Sistem');

  if (!user) return null;

  const presets = [50000, 100000, 250000, 500000, 1000000];

  const handleSubmit = (e) => {
    e.preventDefault();
    if (amount <= 0) return;
    onSubmit(user.id, user.name, amount, note);
  };

  return (
    <div className="modal-backdrop fade-in" onClick={onClose}>
      <div className="modal-content" style={{ maxWidth: '460px' }} onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <Wallet color="#10B981" size={22} />
            <h3>Tambah Saldo: {user.name}</h3>
          </div>
          <button className="modal-close" onClick={onClose}>
            <X size={20} />
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="modal-body">
            <div className="kyc-details">
              <div className="kyc-row">
                <span>Penerima:</span>
                <span>{user.name} (@{user.username})</span>
              </div>
              <div className="kyc-row">
                <span>Saldo Saat Ini:</span>
                <span style={{ color: '#34D399', fontWeight: 700 }}>
                  Rp {(user.balance || 0).toLocaleString('id-ID')}
                </span>
              </div>
            </div>

            <div>
              <label style={{ fontSize: '13px', color: 'var(--text-subtle)', fontWeight: 600, display: 'block', marginBottom: '8px' }}>
                PILIH NOMINAL TOP UP (IDR)
              </label>
              <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', marginBottom: '14px' }}>
                {presets.map((preset) => (
                  <button
                    key={preset}
                    type="button"
                    className={`filter-btn ${amount === preset ? 'active' : ''}`}
                    onClick={() => setAmount(preset)}
                  >
                    Rp {(preset / 1000).toFixed(0)}k
                  </button>
                ))}
              </div>

              <input
                type="number"
                value={amount}
                onChange={(e) => setAmount(Number(e.target.value))}
                min="10000"
                step="10000"
                style={{
                  width: '100%',
                  padding: '12px 16px',
                  background: 'var(--bg-main)',
                  border: '1px solid var(--border-color)',
                  borderRadius: 'var(--radius-sm)',
                  color: '#34D399',
                  fontSize: '20px',
                  fontWeight: 700,
                  outline: 'none',
                }}
              />
            </div>

            <div>
              <label style={{ fontSize: '13px', color: 'var(--text-subtle)', fontWeight: 600, display: 'block', marginBottom: '8px' }}>
                CATATAN / KETERANGAN
              </label>
              <input
                type="text"
                value={note}
                onChange={(e) => setNote(e.target.value)}
                placeholder="Misal: Bonus Registrasi, Top Up Agen..."
                style={{
                  width: '100%',
                  padding: '10px 14px',
                  background: 'var(--bg-main)',
                  border: '1px solid var(--border-color)',
                  borderRadius: 'var(--radius-sm)',
                  color: 'var(--text-main)',
                  fontSize: '14px',
                  outline: 'none',
                }}
              />
            </div>
          </div>

          <div className="modal-footer">
            <button type="button" className="btn btn-secondary" onClick={onClose} disabled={isProcessing}>
              Batal
            </button>
            <button type="submit" className="btn btn-success" disabled={isProcessing}>
              <PlusCircle size={16} />
              {isProcessing ? 'Memproses...' : `Tambah Rp ${amount.toLocaleString('id-ID')}`}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

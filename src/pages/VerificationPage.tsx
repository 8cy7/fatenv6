import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Shield, AlertCircle } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { verifyCode, createVerificationCode } from '../lib/verification';

export default function VerificationPage() {
  const [code, setCode] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [resending, setResending] = useState(false);
  const navigate = useNavigate();
  const { user, profile, refreshProfile } = useAuth();

  useEffect(() => {
    if (!user || !profile) {
      navigate('/login');
      return;
    }

    if (profile.verified) {
      navigate('/dashboard');
      return;
    }

    if (profile.role !== 'user') {
      switch (profile.role) {
        case 'admin':
          navigate('/admin-dashboard');
          break;
        case 'expert':
          navigate('/expert-dashboard');
          break;
        default:
          navigate('/dashboard');
      }
      return;
    }

    if (!profile.verification_code) {
      createVerificationCode(user.id);
    }
  }, [user, profile, navigate]);

  const handleVerify = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      if (!user) {
        setError('User not found');
        return;
      }

      const isValid = await verifyCode(user.id, code);

      if (isValid) {
        await refreshProfile();
        navigate('/dashboard');
      } else {
        setError('Invalid or expired verification code');
      }
    } catch (err) {
      setError('Verification failed. Please try again.');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleResend = async () => {
    if (!user) return;

    setResending(true);
    setError('');

    try {
      await createVerificationCode(user.id);
      alert('A new verification code has been generated. Check the browser console.');
    } catch (err) {
      setError('Failed to resend code. Please try again.');
      console.error(err);
    } finally {
      setResending(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-teal-50 to-cyan-100 flex items-center justify-center p-4">
      <div className="max-w-md w-full">
        <div className="bg-white rounded-2xl shadow-xl p-8">
          <div className="flex justify-center mb-6">
            <div className="bg-teal-100 p-4 rounded-full">
              <Shield className="w-12 h-12 text-teal-600" />
            </div>
          </div>

          <h1 className="text-3xl font-bold text-center text-gray-900 mb-2">
            Verify Your Account
          </h1>
          <p className="text-center text-gray-600 mb-8">
            A verification code has been generated. Check your browser console (F12) to see it.
          </p>

          {error && (
            <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start gap-3">
              <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
              <p className="text-sm text-red-600">{error}</p>
            </div>
          )}

          <form onSubmit={handleVerify} className="space-y-6">
            <div>
              <label htmlFor="code" className="block text-sm font-medium text-gray-700 mb-2">
                Verification Code
              </label>
              <input
                id="code"
                type="text"
                value={code}
                onChange={(e) => setCode(e.target.value)}
                placeholder="Enter 6-digit code"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent transition-all text-center text-2xl tracking-widest"
                maxLength={6}
                pattern="[0-9]{6}"
                required
                disabled={loading}
              />
            </div>

            <button
              type="submit"
              disabled={loading || code.length !== 6}
              className="w-full bg-teal-600 text-white py-3 px-4 rounded-lg font-semibold hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Verifying...' : 'Verify Account'}
            </button>
          </form>

          <div className="mt-6 text-center">
            <button
              type="button"
              onClick={handleResend}
              disabled={resending}
              className="text-teal-600 hover:text-teal-700 font-medium text-sm disabled:opacity-50"
            >
              {resending ? 'Sending...' : "Didn't receive the code? Resend"}
            </button>
          </div>

          <div className="mt-8 p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <p className="text-sm text-blue-800">
              <strong>Note:</strong> Open your browser's developer console (Press F12) to see your verification code.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

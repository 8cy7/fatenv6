import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import type { UserRole } from '../lib/database.types';
import { AlertCircle, ShieldAlert } from 'lucide-react';

interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles?: UserRole[];
  requireVerified?: boolean;
}

export function ProtectedRoute({ children, allowedRoles, requireVerified = false }: ProtectedRouteProps) {
  const { user, profile, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-teal-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!user || !profile) {
    return <Navigate to="/login" replace />;
  }

  if (requireVerified && !profile.verified) {
    return <Navigate to="/verification" replace />;
  }

  if (allowedRoles && !allowedRoles.includes(profile.role)) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 p-4">
        <div className="max-w-md w-full bg-white rounded-2xl shadow-xl p-8">
          <div className="flex justify-center mb-6">
            <div className="bg-red-100 p-4 rounded-full">
              <ShieldAlert className="w-12 h-12 text-red-600" />
            </div>
          </div>

          <h1 className="text-2xl font-bold text-center text-gray-900 mb-4">
            Access Denied
          </h1>

          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
            <p className="text-sm text-red-600">
              You don't have permission to access this page. This page is restricted to {allowedRoles?.join(', ')} users only.
            </p>
          </div>

          <button
            onClick={() => {
              switch (profile.role) {
                case 'admin':
                  window.location.href = '/admin-dashboard';
                  break;
                case 'expert':
                  window.location.href = '/expert-dashboard';
                  break;
                case 'user':
                  window.location.href = profile.verified ? '/dashboard' : '/verification';
                  break;
                default:
                  window.location.href = '/login';
              }
            }}
            className="w-full bg-teal-600 text-white py-3 px-4 rounded-lg font-semibold hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2 transition-all"
          >
            Go to Your Dashboard
          </button>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}

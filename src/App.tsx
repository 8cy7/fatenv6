import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, useLocation } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import HomePage from './pages/HomePage';
import Register from './pages/Register';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import ExpertDashboard from './pages/ExpertDashboard';
import AdminDashboard from './pages/AdminDashboard';
import TwoFactorVerification from './pages/TwoFactorVerification';

function PageTitleUpdater() {
  const location = useLocation();

  useEffect(() => {
    switch (location.pathname) {
      case '/':
        document.title = 'Faten';
        break;
      case '/register':
        document.title = 'إنشاء حساب | Faten';
        break;
      case '/login':
        document.title = 'تسجيل الدخول | Faten';
        break;
      case '/two-factor-verification':
        document.title = 'التحقق بخطوتين | Faten';
        break;
      case '/dashboard':
        document.title = 'الواجهة الرئيسية | Faten';
        break;
      case '/expert-dashboard':
        document.title = 'لوحة الخبراء | Faten';
        break;
      case '/admin-dashboard':
        document.title = 'لوحة الإدارة | Faten';
        break;
      default:
        document.title = 'Faten';
    }
  }, [location]);

  return null;
}

function App() {
  return (
    <Router>
      <AuthProvider>
        <PageTitleUpdater />
        <div className="min-h-screen bg-gray-50 font-sans" dir="rtl">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/register" element={<Register />} />
            <Route path="/login" element={<Login />} />
            <Route path="/two-factor-verification" element={<TwoFactorVerification />} />
            <Route
              path="/dashboard"
              element={
                <ProtectedRoute allowedRoles={['user']}>
                  <Dashboard />
                </ProtectedRoute>
              }
            />
            <Route
              path="/expert-dashboard"
              element={
                <ProtectedRoute allowedRoles={['expert']}>
                  <ExpertDashboard />
                </ProtectedRoute>
              }
            />
            <Route
              path="/admin-dashboard"
              element={
                <ProtectedRoute allowedRoles={['admin']}>
                  <AdminDashboard />
                </ProtectedRoute>
              }
            />
          </Routes>
        </div>
      </AuthProvider>
    </Router>
  );
}

export default App;

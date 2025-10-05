import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { User, AuthError } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';
import type { Database } from '../lib/database.types';
import { createVerificationCode } from '../lib/verification';

type Profile = Database['public']['Tables']['profiles']['Row'];

interface AuthContextType {
  user: User | null;
  profile: Profile | null;
  loading: boolean;
  signUp: (email: string, password: string, fullName: string) => Promise<void>;
  signIn: (email: string, password: string) => Promise<{ profile: Profile }>;
  signOut: () => Promise<void>;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;

    const initAuth = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();

        if (session?.user && mounted) {
          let { data: profileData, error: profileError } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', session.user.id)
            .maybeSingle();

          if (!profileData && !profileError) {
            const { data: newProfile, error: createError } = await supabase
              .from('profiles')
              .insert({
                id: session.user.id,
                email: session.user.email!,
                full_name: session.user.user_metadata?.full_name || 'User',
                role: 'user',
                status: 'active',
                verified: false,
              })
              .select()
              .single();

            if (createError) {
              console.error('Error creating profile:', createError);
            } else {
              profileData = newProfile;
            }
          }

          setUser(session.user);
          setProfile(profileData);
        }
      } catch (error) {
        console.error('Error initializing auth:', error);
      } finally {
        if (mounted) {
          setLoading(false);
        }
      }
    };

    initAuth();

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        if (!mounted) return;

        (async () => {
          if (event === 'SIGNED_IN' && session?.user) {
            let { data: profileData } = await supabase
              .from('profiles')
              .select('*')
              .eq('id', session.user.id)
              .maybeSingle();

            if (!profileData) {
              const { data: newProfile } = await supabase
                .from('profiles')
                .insert({
                  id: session.user.id,
                  email: session.user.email!,
                  full_name: session.user.user_metadata?.full_name || 'User',
                  role: 'user',
                  status: 'active',
                  verified: false,
                })
                .select()
                .single();
              profileData = newProfile;
            }

            setUser(session.user);
            setProfile(profileData);
          } else if (event === 'SIGNED_OUT') {
            setUser(null);
            setProfile(null);
          } else if (event === 'TOKEN_REFRESHED' && session?.user) {
            setUser(session.user);
          }
        })();
      }
    );

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, []);

  const signUp = async (email: string, password: string, fullName: string) => {
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
        },
        emailRedirectTo: undefined,
      },
    });

    if (authError) throw authError;
    if (!authData.user) throw new Error('Sign up failed');

    await new Promise(resolve => setTimeout(resolve, 1000));

    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', authData.user.id)
      .maybeSingle();

    if (profileError) throw profileError;
    if (!profileData) throw new Error('Profile not created');

    setUser(authData.user);
    setProfile(profileData);
  };

  const signIn = async (email: string, password: string) => {
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (authError) throw authError;
    if (!authData.user) throw new Error('Sign in failed');

    let { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', authData.user.id)
      .maybeSingle();

    if (profileError) throw profileError;

    if (!profileData) {
      const { data: newProfile, error: createError } = await supabase
        .from('profiles')
        .insert({
          id: authData.user.id,
          email: authData.user.email!,
          full_name: authData.user.user_metadata?.full_name || 'User',
          role: 'user',
          status: 'active',
          verified: false,
        })
        .select()
        .single();

      if (createError) throw createError;
      profileData = newProfile;
    }

    setUser(authData.user);
    setProfile(profileData);

    return { profile: profileData };
  };

  const signOut = async () => {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;

    setUser(null);
    setProfile(null);
  };

  const refreshProfile = async () => {
    if (!user) return;

    const { data: profileData } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .maybeSingle();

    setProfile(profileData);
  };

  return (
    <AuthContext.Provider value={{ user, profile, loading, signUp, signIn, signOut, refreshProfile }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

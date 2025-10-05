import { supabase } from './supabase';

export function generateVerificationCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

export async function createVerificationCode(userId: string): Promise<string> {
  const code = generateVerificationCode();
  const expiresAt = new Date();
  expiresAt.setMinutes(expiresAt.getMinutes() + 15);

  const { error } = await supabase
    .from('profiles')
    .update({
      verification_code: code,
      verification_code_expires_at: expiresAt.toISOString(),
    })
    .eq('id', userId);

  if (error) {
    console.error('Error creating verification code:', error);
    throw error;
  }

  console.log('🔐 VERIFICATION CODE:', code);
  console.log('⏰ Code expires at:', expiresAt.toLocaleString());

  return code;
}

export async function verifyCode(userId: string, code: string): Promise<boolean> {
  const { data: profile, error } = await supabase
    .from('profiles')
    .select('verification_code, verification_code_expires_at')
    .eq('id', userId)
    .maybeSingle();

  if (error || !profile) {
    console.error('Error fetching profile for verification:', error);
    return false;
  }

  if (!profile.verification_code || !profile.verification_code_expires_at) {
    console.error('No verification code found');
    return false;
  }

  const now = new Date();
  const expiresAt = new Date(profile.verification_code_expires_at);

  if (now > expiresAt) {
    console.error('Verification code expired');
    return false;
  }

  if (profile.verification_code !== code) {
    console.error('Invalid verification code');
    return false;
  }

  const { error: updateError } = await supabase
    .from('profiles')
    .update({
      verified: true,
      verification_code: null,
      verification_code_expires_at: null,
    })
    .eq('id', userId);

  if (updateError) {
    console.error('Error updating verification status:', updateError);
    return false;
  }

  return true;
}

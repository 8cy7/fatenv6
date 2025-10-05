/*
  # Add verification system to profiles

  1. Changes to profiles table
    - Add `verified` column (boolean, default false)
    - Add `verification_code` column (text, nullable)
    - Add `verification_code_expires_at` column (timestamptz, nullable)
  
  2. Security
    - Maintains existing RLS policies
    - Users can only update their own verification status through verification process
*/

-- Add verified column to profiles
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'verified'
  ) THEN
    ALTER TABLE profiles ADD COLUMN verified boolean DEFAULT false;
  END IF;
END $$;

-- Add verification_code column to profiles
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'verification_code'
  ) THEN
    ALTER TABLE profiles ADD COLUMN verification_code text;
  END IF;
END $$;

-- Add verification_code_expires_at column to profiles
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'verification_code_expires_at'
  ) THEN
    ALTER TABLE profiles ADD COLUMN verification_code_expires_at timestamptz;
  END IF;
END $$;

-- Update existing profiles to have verified = false for users
UPDATE profiles
SET verified = false
WHERE role = 'user' AND verified IS NULL;

-- Set admin and expert roles as verified by default
UPDATE profiles
SET verified = true
WHERE role IN ('admin', 'expert') AND verified IS NULL;
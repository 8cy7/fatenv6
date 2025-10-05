/*
  # Add INSERT policy for profiles table

  1. Changes
    - Add INSERT policy to allow authenticated users to create their own profile
    - This enables automatic profile creation on first login/signup

  2. Security
    - Users can only insert their own profile (auth.uid() = id)
    - Maintains existing SELECT and UPDATE policies
*/

-- Add INSERT policy for profiles
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'profiles' 
    AND policyname = 'Users can insert own profile'
  ) THEN
    CREATE POLICY "Users can insert own profile"
      ON profiles FOR INSERT
      TO authenticated
      WITH CHECK (auth.uid() = id);
  END IF;
END $$;
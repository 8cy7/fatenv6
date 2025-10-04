/*
  # Initial Database Schema for Faten Platform

  ## Overview
  This migration creates the complete database schema for the Faten educational platform
  with proper authentication, role-based access control, and user management.

  ## New Tables

  ### 1. `profiles`
  - Stores user profile information linked to auth.users
  - `id` (uuid, primary key) - Links to auth.users.id
  - `email` (text, unique) - User email
  - `full_name` (text) - User's full name
  - `role` (text) - User role: 'user', 'expert', or 'admin'
  - `status` (text) - Account status: 'active', 'suspended', or 'pending'
  - `avatar_url` (text, nullable) - Profile picture URL
  - `created_at` (timestamptz) - Account creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 2. `pre_registered_accounts`
  - Stores admin and expert accounts created in advance by administrators
  - `id` (uuid, primary key)
  - `email` (text, unique) - Email for pre-registered account
  - `role` (text) - Must be 'admin' or 'expert'
  - `full_name` (text) - Full name of the account holder
  - `created_by` (uuid) - ID of admin who created this entry
  - `created_at` (timestamptz) - Creation timestamp
  - `is_used` (boolean) - Whether the account has been activated

  ### 3. `content`
  - Educational content (books, videos, articles)
  - `id` (uuid, primary key)
  - `title` (text) - Content title
  - `description` (text) - Content description
  - `type` (text) - Content type: 'book', 'video', or 'article'
  - `category` (text) - Content category
  - `author` (text) - Content author
  - `image_url` (text) - Content thumbnail/cover image
  - `status` (text) - 'published', 'draft', or 'archived'
  - `created_by` (uuid) - Expert who created the content
  - `created_at` (timestamptz)
  - `views` (integer) - View count
  - `likes` (integer) - Like count

  ### 4. `discussions`
  - Discussion forums created by experts
  - `id` (uuid, primary key)
  - `title` (text) - Discussion title
  - `description` (text) - Discussion description
  - `created_by` (uuid) - Expert who created the discussion
  - `created_at` (timestamptz)
  - `participants_count` (integer) - Number of participants
  - `status` (text) - 'active', 'closed', or 'archived'

  ### 5. `discussion_messages`
  - Messages within discussions
  - `id` (uuid, primary key)
  - `discussion_id` (uuid) - Parent discussion
  - `user_id` (uuid) - Message author
  - `content` (text) - Message content
  - `created_at` (timestamptz)
  - `is_deleted` (boolean) - Soft delete flag

  ### 6. `events`
  - Events and activities
  - `id` (uuid, primary key)
  - `title` (text) - Event title
  - `type` (text) - Event type
  - `date` (timestamptz) - Event date
  - `description` (text) - Event description
  - `created_by` (uuid) - Creator ID
  - `status` (text) - 'upcoming', 'ongoing', or 'completed'
  - `created_at` (timestamptz)

  ### 7. `notifications`
  - User notifications
  - `id` (uuid, primary key)
  - `user_id` (uuid) - Recipient user
  - `title` (text) - Notification title
  - `message` (text) - Notification message
  - `type` (text) - Notification type
  - `is_read` (boolean) - Read status
  - `action_url` (text, nullable) - Optional action link
  - `created_at` (timestamptz)

  ### 8. `user_content_interactions`
  - Tracks user interactions with content
  - `id` (uuid, primary key)
  - `user_id` (uuid)
  - `content_id` (uuid)
  - `is_liked` (boolean)
  - `is_completed` (boolean)
  - `time_spent` (integer) - Minutes spent
  - `last_accessed` (timestamptz)

  ### 9. `discussion_participants`
  - Tracks discussion participation
  - `id` (uuid, primary key)
  - `discussion_id` (uuid)
  - `user_id` (uuid)
  - `joined_at` (timestamptz)
  - `messages_count` (integer)

  ## Security

  ### Row Level Security (RLS)
  - All tables have RLS enabled
  - Restrictive policies ensure users can only access their own data
  - Admins have full access to all data
  - Experts can manage their own content and discussions

  ### Database Trigger
  - Automatic profile creation when a new user signs up
  - Checks `pre_registered_accounts` to assign correct role
  - Default role is 'user' unless email is pre-registered

  ## Important Notes
  1. Admin and Expert accounts should be pre-registered using `pre_registered_accounts` table
  2. Regular users can sign up normally and automatically get 'user' role
  3. The trigger ensures seamless role assignment during signup
  4. All foreign key relationships are properly enforced
  5. Indexes are added for frequently queried columns
*/

-- Create enum types for better type safety
DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('user', 'expert', 'admin');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE user_status AS ENUM ('active', 'suspended', 'pending');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE content_type AS ENUM ('book', 'video', 'article');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE content_status AS ENUM ('published', 'draft', 'archived');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE discussion_status AS ENUM ('active', 'closed', 'archived');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE event_status AS ENUM ('upcoming', 'ongoing', 'completed');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Table: profiles
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  full_name text NOT NULL,
  role user_role NOT NULL DEFAULT 'user',
  status user_status NOT NULL DEFAULT 'pending',
  avatar_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table: pre_registered_accounts
CREATE TABLE IF NOT EXISTS pre_registered_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  role user_role NOT NULL CHECK (role IN ('admin', 'expert')),
  full_name text NOT NULL,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz DEFAULT now(),
  is_used boolean DEFAULT false
);

-- Table: content
CREATE TABLE IF NOT EXISTS content (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  type content_type NOT NULL,
  category text NOT NULL,
  author text NOT NULL,
  image_url text NOT NULL,
  status content_status NOT NULL DEFAULT 'draft',
  created_by uuid REFERENCES profiles(id) NOT NULL,
  created_at timestamptz DEFAULT now(),
  views integer DEFAULT 0,
  likes integer DEFAULT 0
);

-- Table: discussions
CREATE TABLE IF NOT EXISTS discussions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL DEFAULT '',
  created_by uuid REFERENCES profiles(id) NOT NULL,
  created_at timestamptz DEFAULT now(),
  participants_count integer DEFAULT 0,
  status discussion_status NOT NULL DEFAULT 'active'
);

-- Table: discussion_messages
CREATE TABLE IF NOT EXISTS discussion_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  discussion_id uuid REFERENCES discussions(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES profiles(id) NOT NULL,
  content text NOT NULL,
  created_at timestamptz DEFAULT now(),
  is_deleted boolean DEFAULT false
);

-- Table: events
CREATE TABLE IF NOT EXISTS events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  type text NOT NULL,
  date timestamptz NOT NULL,
  description text NOT NULL,
  created_by uuid REFERENCES profiles(id) NOT NULL,
  status event_status NOT NULL DEFAULT 'upcoming',
  created_at timestamptz DEFAULT now()
);

-- Table: notifications
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title text NOT NULL,
  message text NOT NULL,
  type text NOT NULL,
  is_read boolean DEFAULT false,
  action_url text,
  created_at timestamptz DEFAULT now()
);

-- Table: user_content_interactions
CREATE TABLE IF NOT EXISTS user_content_interactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  content_id uuid REFERENCES content(id) ON DELETE CASCADE NOT NULL,
  is_liked boolean DEFAULT false,
  is_completed boolean DEFAULT false,
  time_spent integer DEFAULT 0,
  last_accessed timestamptz DEFAULT now(),
  UNIQUE(user_id, content_id)
);

-- Table: discussion_participants
CREATE TABLE IF NOT EXISTS discussion_participants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  discussion_id uuid REFERENCES discussions(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  joined_at timestamptz DEFAULT now(),
  messages_count integer DEFAULT 0,
  UNIQUE(discussion_id, user_id)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_content_created_by ON content(created_by);
CREATE INDEX IF NOT EXISTS idx_content_status ON content(status);
CREATE INDEX IF NOT EXISTS idx_discussions_created_by ON discussions(created_by);
CREATE INDEX IF NOT EXISTS idx_discussion_messages_discussion_id ON discussion_messages(discussion_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(user_id, is_read);

-- Enable Row Level Security on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE pre_registered_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE content ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussions ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_content_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_participants ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile (except role)"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id AND (SELECT role FROM profiles WHERE id = auth.uid()) = role);

CREATE POLICY "Admins can view all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can update all profiles"
  ON profiles FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies for pre_registered_accounts
CREATE POLICY "Only admins can view pre_registered_accounts"
  ON pre_registered_accounts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Only admins can insert pre_registered_accounts"
  ON pre_registered_accounts FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Only admins can update pre_registered_accounts"
  ON pre_registered_accounts FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Only admins can delete pre_registered_accounts"
  ON pre_registered_accounts FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies for content
CREATE POLICY "Anyone can view published content"
  ON content FOR SELECT
  TO authenticated
  USING (status = 'published' OR created_by = auth.uid() OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'expert'))
  );

CREATE POLICY "Experts and admins can insert content"
  ON content FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('expert', 'admin')
    )
  );

CREATE POLICY "Creators and admins can update content"
  ON content FOR UPDATE
  TO authenticated
  USING (
    created_by = auth.uid() OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Creators and admins can delete content"
  ON content FOR DELETE
  TO authenticated
  USING (
    created_by = auth.uid() OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- RLS Policies for discussions
CREATE POLICY "Anyone can view active discussions"
  ON discussions FOR SELECT
  TO authenticated
  USING (status = 'active' OR created_by = auth.uid() OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Experts and admins can create discussions"
  ON discussions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('expert', 'admin')
    )
  );

CREATE POLICY "Creators and admins can update discussions"
  ON discussions FOR UPDATE
  TO authenticated
  USING (
    created_by = auth.uid() OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- RLS Policies for discussion_messages
CREATE POLICY "Participants can view discussion messages"
  ON discussion_messages FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM discussion_participants
      WHERE discussion_id = discussion_messages.discussion_id
      AND user_id = auth.uid()
    ) OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users can insert their own messages"
  ON discussion_messages FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own messages"
  ON discussion_messages FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- RLS Policies for events
CREATE POLICY "Anyone can view events"
  ON events FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Experts and admins can create events"
  ON events FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('expert', 'admin')
    )
  );

CREATE POLICY "Creators and admins can update events"
  ON events FOR UPDATE
  TO authenticated
  USING (
    created_by = auth.uid() OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- RLS Policies for notifications
CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "System can create notifications"
  ON notifications FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- RLS Policies for user_content_interactions
CREATE POLICY "Users can view own interactions"
  ON user_content_interactions FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can manage own interactions"
  ON user_content_interactions FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own interactions"
  ON user_content_interactions FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- RLS Policies for discussion_participants
CREATE POLICY "Users can view discussion participants"
  ON discussion_participants FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can join discussions"
  ON discussion_participants FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Function: Automatic profile creation with role detection
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  pre_reg_record RECORD;
BEGIN
  -- Check if email exists in pre_registered_accounts
  SELECT * INTO pre_reg_record
  FROM pre_registered_accounts
  WHERE email = NEW.email AND is_used = false;

  IF FOUND THEN
    -- Pre-registered admin or expert
    INSERT INTO public.profiles (id, email, full_name, role, status, created_at, updated_at)
    VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NEW.raw_user_meta_data->>'full_name', pre_reg_record.full_name),
      pre_reg_record.role,
      'active',
      now(),
      now()
    );
    
    -- Mark the pre-registered account as used
    UPDATE pre_registered_accounts
    SET is_used = true
    WHERE email = NEW.email;
  ELSE
    -- Regular user signup
    INSERT INTO public.profiles (id, email, full_name, role, status, created_at, updated_at)
    VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
      'user',
      'active',
      now(),
      now()
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: Execute handle_new_user function on auth.users insert
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-update updated_at for profiles
DROP TRIGGER IF EXISTS on_profile_updated ON profiles;
CREATE TRIGGER on_profile_updated
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
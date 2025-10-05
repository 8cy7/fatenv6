export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type UserRole = 'user' | 'expert' | 'admin';
export type UserStatus = 'active' | 'suspended' | 'pending';
export type ContentType = 'book' | 'video' | 'article';
export type ContentStatus = 'published' | 'draft' | 'archived';
export type DiscussionStatus = 'active' | 'closed' | 'archived';
export type EventStatus = 'upcoming' | 'ongoing' | 'completed';

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          email: string;
          full_name: string;
          role: UserRole;
          status: UserStatus;
          avatar_url: string | null;
          verified: boolean;
          verification_code: string | null;
          verification_code_expires_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          email: string;
          full_name: string;
          role?: UserRole;
          status?: UserStatus;
          avatar_url?: string | null;
          verified?: boolean;
          verification_code?: string | null;
          verification_code_expires_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          email?: string;
          full_name?: string;
          role?: UserRole;
          status?: UserStatus;
          avatar_url?: string | null;
          verified?: boolean;
          verification_code?: string | null;
          verification_code_expires_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      pre_registered_accounts: {
        Row: {
          id: string;
          email: string;
          role: UserRole;
          full_name: string;
          created_by: string | null;
          created_at: string;
          is_used: boolean;
        };
        Insert: {
          id?: string;
          email: string;
          role: UserRole;
          full_name: string;
          created_by?: string | null;
          created_at?: string;
          is_used?: boolean;
        };
        Update: {
          id?: string;
          email?: string;
          role?: UserRole;
          full_name?: string;
          created_by?: string | null;
          created_at?: string;
          is_used?: boolean;
        };
      };
      content: {
        Row: {
          id: string;
          title: string;
          description: string;
          type: ContentType;
          category: string;
          author: string;
          image_url: string;
          status: ContentStatus;
          created_by: string;
          created_at: string;
          views: number;
          likes: number;
        };
        Insert: {
          id?: string;
          title: string;
          description: string;
          type: ContentType;
          category: string;
          author: string;
          image_url: string;
          status?: ContentStatus;
          created_by: string;
          created_at?: string;
          views?: number;
          likes?: number;
        };
        Update: {
          id?: string;
          title?: string;
          description?: string;
          type?: ContentType;
          category?: string;
          author?: string;
          image_url?: string;
          status?: ContentStatus;
          created_by?: string;
          created_at?: string;
          views?: number;
          likes?: number;
        };
      };
      discussions: {
        Row: {
          id: string;
          title: string;
          description: string;
          created_by: string;
          created_at: string;
          participants_count: number;
          status: DiscussionStatus;
        };
        Insert: {
          id?: string;
          title: string;
          description?: string;
          created_by: string;
          created_at?: string;
          participants_count?: number;
          status?: DiscussionStatus;
        };
        Update: {
          id?: string;
          title?: string;
          description?: string;
          created_by?: string;
          created_at?: string;
          participants_count?: number;
          status?: DiscussionStatus;
        };
      };
      discussion_messages: {
        Row: {
          id: string;
          discussion_id: string;
          user_id: string;
          content: string;
          created_at: string;
          is_deleted: boolean;
        };
        Insert: {
          id?: string;
          discussion_id: string;
          user_id: string;
          content: string;
          created_at?: string;
          is_deleted?: boolean;
        };
        Update: {
          id?: string;
          discussion_id?: string;
          user_id?: string;
          content?: string;
          created_at?: string;
          is_deleted?: boolean;
        };
      };
      events: {
        Row: {
          id: string;
          title: string;
          type: string;
          date: string;
          description: string;
          created_by: string;
          status: EventStatus;
          created_at: string;
        };
        Insert: {
          id?: string;
          title: string;
          type: string;
          date: string;
          description: string;
          created_by: string;
          status?: EventStatus;
          created_at?: string;
        };
        Update: {
          id?: string;
          title?: string;
          type?: string;
          date?: string;
          description?: string;
          created_by?: string;
          status?: EventStatus;
          created_at?: string;
        };
      };
      notifications: {
        Row: {
          id: string;
          user_id: string;
          title: string;
          message: string;
          type: string;
          is_read: boolean;
          action_url: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          title: string;
          message: string;
          type: string;
          is_read?: boolean;
          action_url?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          title?: string;
          message?: string;
          type?: string;
          is_read?: boolean;
          action_url?: string | null;
          created_at?: string;
        };
      };
      user_content_interactions: {
        Row: {
          id: string;
          user_id: string;
          content_id: string;
          is_liked: boolean;
          is_completed: boolean;
          time_spent: number;
          last_accessed: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          content_id: string;
          is_liked?: boolean;
          is_completed?: boolean;
          time_spent?: number;
          last_accessed?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          content_id?: string;
          is_liked?: boolean;
          is_completed?: boolean;
          time_spent?: number;
          last_accessed?: string;
        };
      };
      discussion_participants: {
        Row: {
          id: string;
          discussion_id: string;
          user_id: string;
          joined_at: string;
          messages_count: number;
        };
        Insert: {
          id?: string;
          discussion_id: string;
          user_id: string;
          joined_at?: string;
          messages_count?: number;
        };
        Update: {
          id?: string;
          discussion_id?: string;
          user_id?: string;
          joined_at?: string;
          messages_count?: number;
        };
      };
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      [_ in never]: never;
    };
    Enums: {
      user_role: UserRole;
      user_status: UserStatus;
      content_type: ContentType;
      content_status: ContentStatus;
      discussion_status: DiscussionStatus;
      event_status: EventStatus;
    };
  };
}

-- Complete Clean Schema for Emotional Spiral App (Safe Version)
-- This handles existing triggers and functions safely

-- First, drop existing triggers and functions if they exist
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Drop all existing tables to start fresh
DROP TABLE IF EXISTS public.sessions CASCADE;
DROP TABLE IF EXISTS public.emotion_analysis CASCADE;
DROP TABLE IF EXISTS public.emotion_analyses CASCADE;
DROP TABLE IF EXISTS public.journal_entries CASCADE;
DROP TABLE IF EXISTS public.ai_journal_entries CASCADE;
DROP TABLE IF EXISTS public.conversations CASCADE;
DROP TABLE IF EXISTS public.journals CASCADE;
DROP TABLE IF EXISTS public.user_profiles CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.practice_sessions CASCADE;
DROP TABLE IF EXISTS public.user_progress CASCADE;

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create unified user_profiles table (consolidating users, profiles, user_profiles)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    name TEXT NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    spiral_stage TEXT DEFAULT 'beige',
    stage_scores JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create journals table (main journal entries)
CREATE TABLE public.journals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT,
    content TEXT,
    transcript TEXT,
    audio_url TEXT,
    mood_score INTEGER,
    tags TEXT[],
    input_method TEXT DEFAULT 'text',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create emotion_analyses table (for emotional analysis results)
CREATE TABLE public.emotion_analyses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    journal_id UUID REFERENCES public.journals(id) ON DELETE CASCADE,
    primary_emotion TEXT,
    sentiment_score DECIMAL,
    emotions JSONB DEFAULT '{}',
    spiral_color TEXT,
    insights TEXT,
    suggestions TEXT[],
    confidence_score DECIMAL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create voice_journal_entries table (specific for voice journaling)
CREATE TABLE public.voice_journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    transcript TEXT NOT NULL,
    analysis_json JSONB DEFAULT '{}',
    emotional_tone JSONB DEFAULT '{}',
    growth_themes TEXT[],
    spiral_stage_analysis JSONB DEFAULT '{}',
    reflection_prompt TEXT,
    reflection_response TEXT,
    duration INTEGER,
    offline_mode BOOLEAN DEFAULT FALSE,
    api_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create ai_journal_entries table (specific for AI conversations)
CREATE TABLE public.ai_journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    input_text TEXT NOT NULL,
    reflective_questions JSONB DEFAULT '[]',
    conversation_history JSONB DEFAULT '[]',
    offline_mode BOOLEAN DEFAULT FALSE,
    api_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create conversations table (for general AI conversations)
CREATE TABLE public.conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT,
    messages JSONB NOT NULL DEFAULT '[]',
    conversation_type TEXT DEFAULT 'general',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create sessions table (for comprehensive session tracking)
CREATE TABLE public.sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_type TEXT NOT NULL,
    transcript TEXT,
    audio_url TEXT,
    emotional_tone JSONB DEFAULT '{}',
    growth_themes TEXT[],
    spiral_stage JSONB DEFAULT '{}',
    reflection_prompt TEXT,
    reflection_response TEXT,
    duration INTEGER,
    input_method TEXT DEFAULT 'voice',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create practice_sessions table (for mindfulness/practice tracking)
CREATE TABLE public.practice_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    practice_type TEXT NOT NULL,
    duration INTEGER,
    notes TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_progress table (for tracking user growth)
CREATE TABLE public.user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    metric_type TEXT NOT NULL,
    metric_value JSONB NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emotion_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voice_journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.practice_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can manage their own journals" ON public.journals;
DROP POLICY IF EXISTS "Users can manage their own emotion analyses" ON public.emotion_analyses;
DROP POLICY IF EXISTS "Users can manage their own voice journal entries" ON public.voice_journal_entries;
DROP POLICY IF EXISTS "Users can manage their own AI journal entries" ON public.ai_journal_entries;
DROP POLICY IF EXISTS "Users can manage their own conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can manage their own sessions" ON public.sessions;
DROP POLICY IF EXISTS "Users can manage their own practice sessions" ON public.practice_sessions;
DROP POLICY IF EXISTS "Users can manage their own progress" ON public.user_progress;

-- Create RLS policies for user_profiles
CREATE POLICY "Users can view their own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Create RLS policies for journals
CREATE POLICY "Users can manage their own journals" ON public.journals
    FOR ALL USING (auth.uid() = user_id);

-- Create RLS policies for emotion_analyses
CREATE POLICY "Users can manage their own emotion analyses" ON public.emotion_analyses
    FOR ALL USING (auth.uid() = user_id);

-- Create RLS policies for voice_journal_entries
CREATE POLICY "Users can manage their own voice journal entries" ON public.voice_journal_entries
    FOR ALL USING (auth.uid() = user_id);

-- Create RLS policies for ai_journal_entries
CREATE POLICY "Users can manage their own AI journal entries" ON public.ai_journal_entries
    FOR ALL USING (auth.uid() = user_id);

-- Create RLS policies for conversations
CREATE POLICY "Users can manage their own conversations" ON public.conversations
    FOR ALL USING (auth.uid() = user_id);

-- Create RLS policies for sessions
CREATE POLICY "Users can manage their own sessions" ON public.sessions
    FOR ALL USING (auth.uid() = user_id);

-- Create RLS policies for practice_sessions
CREATE POLICY "Users can manage their own practice sessions" ON public.practice_sessions
    FOR ALL USING (auth.uid() = user_id);

-- Create RLS policies for user_progress
CREATE POLICY "Users can manage their own progress" ON public.user_progress
    FOR ALL USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_journals_user_id ON public.journals(user_id);
CREATE INDEX IF NOT EXISTS idx_journals_created_at ON public.journals(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_emotion_analyses_user_id ON public.emotion_analyses(user_id);
CREATE INDEX IF NOT EXISTS idx_emotion_analyses_journal_id ON public.emotion_analyses(journal_id);
CREATE INDEX IF NOT EXISTS idx_voice_journal_entries_user_id ON public.voice_journal_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_voice_journal_entries_created_at ON public.voice_journal_entries(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_journal_entries_user_id ON public.ai_journal_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_journal_entries_created_at ON public.ai_journal_entries(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON public.conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_session_type ON public.sessions(session_type);
CREATE INDEX IF NOT EXISTS idx_practice_sessions_user_id ON public.practice_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON public.user_progress(user_id);

-- Create functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;
DROP TRIGGER IF EXISTS update_journals_updated_at ON public.journals;
DROP TRIGGER IF EXISTS update_voice_journal_entries_updated_at ON public.voice_journal_entries;
DROP TRIGGER IF EXISTS update_ai_journal_entries_updated_at ON public.ai_journal_entries;
DROP TRIGGER IF EXISTS update_conversations_updated_at ON public.conversations;
DROP TRIGGER IF EXISTS update_sessions_updated_at ON public.sessions;

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_journals_updated_at BEFORE UPDATE ON public.journals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_voice_journal_entries_updated_at BEFORE UPDATE ON public.voice_journal_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ai_journal_entries_updated_at BEFORE UPDATE ON public.ai_journal_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON public.conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sessions_updated_at BEFORE UPDATE ON public.sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create a function to handle user profile creation on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, name, display_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
    );
    RETURN NEW;
EXCEPTION
    WHEN others THEN
        -- If there's any error, just return NEW to not block user creation
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create user profile on signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Success message
SELECT 'Database schema created successfully! All tables, indexes, RLS policies, and triggers are in place.' AS status;

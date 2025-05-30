-- Drop existing tables to recreate with correct schema
DROP TABLE IF EXISTS emotion_analyses CASCADE;
DROP TABLE IF EXISTS journals CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;
DROP TABLE IF EXISTS journal_entries CASCADE;
DROP TABLE IF EXISTS ai_journal_entries CASCADE;
DROP TABLE IF EXISTS conversations CASCADE;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create user_profiles table with correct schema
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    name TEXT NOT NULL,
    display_name TEXT,
    spiral_stage TEXT DEFAULT 'beige',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create journals table
CREATE TABLE journals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT,
    content TEXT,
    transcript TEXT,
    mood_score INTEGER,
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create emotion_analyses table
CREATE TABLE emotion_analyses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    journal_id UUID REFERENCES journals(id) ON DELETE CASCADE,
    primary_emotion TEXT,
    sentiment_score DECIMAL,
    emotions JSONB,
    insights TEXT,
    suggestions TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create journal_entries table (for voice journal)
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    transcript TEXT NOT NULL,
    analysis_json JSONB,
    offline_mode BOOLEAN DEFAULT FALSE,
    api_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create ai_journal_entries table (for AI journal)
CREATE TABLE ai_journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    input_text TEXT NOT NULL,
    reflective_questions JSONB,
    offline_mode BOOLEAN DEFAULT FALSE,
    api_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create conversations table
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT,
    messages JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE journals ENABLE ROW LEVEL SECURITY;
ALTER TABLE emotion_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can manage their own profile" ON user_profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "Users can manage their own journals" ON journals FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own emotion analyses" ON emotion_analyses FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own journal entries" ON journal_entries FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own AI journal entries" ON ai_journal_entries FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own conversations" ON conversations FOR ALL USING (auth.uid() = user_id);

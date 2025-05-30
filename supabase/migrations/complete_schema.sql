-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create user_profiles table
CREATE OR REPLACE FUNCTION create_user_profiles_table_if_not_exists()
RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'user_profiles') THEN
        CREATE TABLE user_profiles (
            id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
            email TEXT NOT NULL,
            display_name TEXT,
            avatar_url TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Users can view their own profile"
            ON user_profiles
            FOR SELECT
            USING (auth.uid() = id);
            
        CREATE POLICY "Users can update their own profile"
            ON user_profiles
            FOR UPDATE
            USING (auth.uid() = id);
            
        CREATE POLICY "Users can insert their own profile"
            ON user_profiles
            FOR INSERT
            WITH CHECK (auth.uid() = id);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create journals table
CREATE OR REPLACE FUNCTION create_journal_tables_if_not_exist()
RETURNS void AS $$
BEGIN
    -- Create journals table
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'journals') THEN
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
        
        ALTER TABLE journals ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Users can manage their own journals"
            ON journals
            FOR ALL
            USING (auth.uid() = user_id);
    END IF;
    
    -- Create emotion_analyses table
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'emotion_analyses') THEN
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
        
        ALTER TABLE emotion_analyses ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Users can manage their own emotion analyses"
            ON emotion_analyses
            FOR ALL
            USING (auth.uid() = user_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create conversation tables
CREATE OR REPLACE FUNCTION create_conversation_tables_if_not_exist()
RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'conversations') THEN
        CREATE TABLE conversations (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
            title TEXT,
            messages JSONB NOT NULL DEFAULT '[]',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Users can manage their own conversations"
            ON conversations
            FOR ALL
            USING (auth.uid() = user_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create journal_entries table (for voice journal)
CREATE OR REPLACE FUNCTION create_journal_entries_table_if_not_exists()
RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'journal_entries') THEN
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
        
        ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Users can manage their own journal entries"
            ON journal_entries
            FOR ALL
            USING (auth.uid() = user_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create ai_journal_entries table (for AI journal)
CREATE OR REPLACE FUNCTION create_ai_journal_entries_table_if_not_exists()
RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'ai_journal_entries') THEN
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
        
        ALTER TABLE ai_journal_entries ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Users can manage their own AI journal entries"
            ON ai_journal_entries
            FOR ALL
            USING (auth.uid() = user_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Execute all table creation functions
SELECT create_user_profiles_table_if_not_exists();
SELECT create_journal_tables_if_not_exist();
SELECT create_conversation_tables_if_not_exist();
SELECT create_journal_entries_table_if_not_exists();
SELECT create_ai_journal_entries_table_if_not_exists();

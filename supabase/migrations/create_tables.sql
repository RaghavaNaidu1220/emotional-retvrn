-- Create journal_entries table if it doesn't exist
CREATE OR REPLACE FUNCTION create_journal_entries_table_if_not_exists()
RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'journal_entries') THEN
        CREATE TABLE journal_entries (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID NOT NULL,
            transcript TEXT NOT NULL,
            analysis_json JSONB,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Add RLS policies
        ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Users can view their own journal entries"
            ON journal_entries
            FOR SELECT
            USING (auth.uid() = user_id);
            
        CREATE POLICY "Users can insert their own journal entries"
            ON journal_entries
            FOR INSERT
            WITH CHECK (auth.uid() = user_id);
            
        CREATE POLICY "Users can update their own journal entries"
            ON journal_entries
            FOR UPDATE
            USING (auth.uid() = user_id);
            
        CREATE POLICY "Users can delete their own journal entries"
            ON journal_entries
            FOR DELETE
            USING (auth.uid() = user_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create ai_journal_entries table if it doesn't exist
CREATE OR REPLACE FUNCTION create_ai_journal_entries_table_if_not_exists()
RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'ai_journal_entries') THEN
        CREATE TABLE ai_journal_entries (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID NOT NULL,
            input_text TEXT NOT NULL,
            reflective_questions JSONB,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Add RLS policies
        ALTER TABLE ai_journal_entries ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Users can view their own AI journal entries"
            ON ai_journal_entries
            FOR SELECT
            USING (auth.uid() = user_id);
            
        CREATE POLICY "Users can insert their own AI journal entries"
            ON ai_journal_entries
            FOR INSERT
            WITH CHECK (auth.uid() = user_id);
            
        CREATE POLICY "Users can update their own AI journal entries"
            ON ai_journal_entries
            FOR UPDATE
            USING (auth.uid() = user_id);
            
        CREATE POLICY "Users can delete their own AI journal entries"
            ON ai_journal_entries
            FOR DELETE
            USING (auth.uid() = user_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

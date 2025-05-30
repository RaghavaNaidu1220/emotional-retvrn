-- Function to check if a table exists
CREATE OR REPLACE FUNCTION public.check_table_exists(table_name text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  table_exists boolean;
BEGIN
  SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public'
    AND table_name = $1
  ) INTO table_exists;
  
  IF NOT table_exists THEN
    RAISE EXCEPTION 'Table % does not exist', $1;
  END IF;
  
  RETURN table_exists;
END;
$$;

-- Function to create users table if it doesn't exist
CREATE OR REPLACE FUNCTION public.create_users_table()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY,
    email TEXT NOT NULL,
    name TEXT NOT NULL,
    age INTEGER,
    spiral_stage TEXT DEFAULT 'beige',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
  );
  
  -- Add RLS policy
  ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
  
  -- Create policies
  DROP POLICY IF EXISTS "Users can view their own data" ON public.users;
  CREATE POLICY "Users can view their own data" ON public.users
    FOR SELECT USING (auth.uid() = id);
    
  DROP POLICY IF EXISTS "Users can update their own data" ON public.users;
  CREATE POLICY "Users can update their own data" ON public.users
    FOR UPDATE USING (auth.uid() = id);
    
  DROP POLICY IF EXISTS "Users can insert their own data" ON public.users;
  CREATE POLICY "Users can insert their own data" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);
END;
$$;

-- Function to create journals table if it doesn't exist
CREATE OR REPLACE FUNCTION public.create_journals_table()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  CREATE TABLE IF NOT EXISTS public.journals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    content TEXT,
    transcript TEXT,
    audio_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
  );
  
  -- Add RLS policy
  ALTER TABLE public.journals ENABLE ROW LEVEL SECURITY;
  
  -- Create policies
  DROP POLICY IF EXISTS "Users can view their own journals" ON public.journals;
  CREATE POLICY "Users can view their own journals" ON public.journals
    FOR SELECT USING (auth.uid() = user_id);
    
  DROP POLICY IF EXISTS "Users can insert their own journals" ON public.journals;
  CREATE POLICY "Users can insert their own journals" ON public.journals
    FOR INSERT WITH CHECK (auth.uid() = user_id);
END;
$$;

-- Function to create emotion_analysis table if it doesn't exist
CREATE OR REPLACE FUNCTION public.create_emotion_analysis_table()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  CREATE TABLE IF NOT EXISTS public.emotion_analysis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_id UUID NOT NULL,
    emotions JSONB NOT NULL,
    spiral_color TEXT NOT NULL,
    suggestions TEXT[] NOT NULL,
    confidence_score DECIMAL NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
  );
  
  -- Add RLS policy
  ALTER TABLE public.emotion_analysis ENABLE ROW LEVEL SECURITY;
  
  -- Create policies
  DROP POLICY IF EXISTS "Users can view their own analyses" ON public.emotion_analysis;
  CREATE POLICY "Users can view their own analyses" ON public.emotion_analysis
    FOR SELECT USING (
      EXISTS (
        SELECT 1 FROM public.journals
        WHERE public.journals.id = public.emotion_analysis.journal_id
        AND public.journals.user_id = auth.uid()
      )
    );
    
  DROP POLICY IF EXISTS "Users can insert their own analyses" ON public.emotion_analysis;
  CREATE POLICY "Users can insert their own analyses" ON public.emotion_analysis
    FOR INSERT WITH CHECK (
      EXISTS (
        SELECT 1 FROM public.journals
        WHERE public.journals.id = public.emotion_analysis.journal_id
        AND public.journals.user_id = auth.uid()
      )
    );
END;
$$;

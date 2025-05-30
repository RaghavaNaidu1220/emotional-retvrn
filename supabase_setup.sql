-- Users table
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  age INTEGER,
  spiral_stage TEXT DEFAULT 'beige',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Journals table
CREATE TABLE IF NOT EXISTS public.journals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id),
  content TEXT,
  transcript TEXT,
  audio_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Emotion Analysis table
CREATE TABLE IF NOT EXISTS public.emotion_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  journal_id UUID REFERENCES public.journals(id),
  emotions JSONB NOT NULL,
  spiral_color TEXT NOT NULL,
  suggestions TEXT[] NOT NULL,
  confidence_score DECIMAL NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emotion_analysis ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own data" ON public.users
  FOR SELECT USING (auth.uid() = id);
  
CREATE POLICY "Users can update their own data" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Journals policies
CREATE POLICY "Users can view their own journals" ON public.journals
  FOR SELECT USING (auth.uid() = user_id);
  
CREATE POLICY "Users can insert their own journals" ON public.journals
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Emotion Analysis policies
CREATE POLICY "Users can view their own analyses" ON public.emotion_analysis
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.journals
      WHERE public.journals.id = public.emotion_analysis.journal_id
      AND public.journals.user_id = auth.uid()
    )
  );
  
CREATE POLICY "Users can insert their own analyses" ON public.emotion_analysis
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.journals
      WHERE public.journals.id = public.emotion_analysis.journal_id
      AND public.journals.user_id = auth.uid()
    )
  );

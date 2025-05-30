-- Add age column to user_profiles table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'age'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN age integer;
    END IF;
END $$;

-- Update the handle_new_user function to include age
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, name, display_name, age, spiral_stage)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', 'User'),
    COALESCE(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', 'User'),
    CASE 
      WHEN new.raw_user_meta_data->>'age' IS NOT NULL 
      THEN (new.raw_user_meta_data->>'age')::integer 
      ELSE NULL 
    END,
    'beige'
  );
  RETURN new;
EXCEPTION
  WHEN others THEN
    -- Log the error but don't prevent user creation
    RAISE WARNING 'Failed to create user profile: %', SQLERRM;
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

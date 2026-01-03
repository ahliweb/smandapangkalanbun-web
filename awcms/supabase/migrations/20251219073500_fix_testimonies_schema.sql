-- Migration: Add missing columns to testimonies table
-- Required by TestimonyManager form fields

DO $$ 
BEGIN
    -- Only proceed if 'testimonies' table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'testimonies' AND table_schema = 'public') THEN
        
        -- Add published_at column if it doesn't exist
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'testimonies' AND column_name = 'published_at') THEN
            ALTER TABLE public.testimonies ADD COLUMN published_at TIMESTAMPTZ;
        END IF;

        -- Add slug column if it doesn't exist
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'testimonies' AND column_name = 'slug') THEN
            ALTER TABLE public.testimonies ADD COLUMN slug TEXT UNIQUE;
        END IF;

        -- Add author_position column if it doesn't exist
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'testimonies' AND column_name = 'author_position') THEN
            ALTER TABLE public.testimonies ADD COLUMN author_position TEXT;
        END IF;

        -- Add author_image column if it doesn't exist
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'testimonies' AND column_name = 'author_image') THEN
            ALTER TABLE public.testimonies ADD COLUMN author_image TEXT;
        END IF;

        -- Add category_id column if it doesn't exist
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'testimonies' AND column_name = 'category_id') THEN
             -- Check if categories table exists before referencing it
             IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories' AND table_schema = 'public') THEN
                ALTER TABLE public.testimonies ADD COLUMN category_id UUID REFERENCES public.categories(id);
             ELSE
                ALTER TABLE public.testimonies ADD COLUMN category_id UUID;
             END IF;
        END IF;

         -- Add index for faster lookup by status
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_testimonies_status ON public.testimonies(status)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_testimonies_published_at ON public.testimonies(published_at)';
        
    END IF;
END $$;

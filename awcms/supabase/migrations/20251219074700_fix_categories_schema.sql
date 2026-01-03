-- Migration: Add missing columns to categories table
-- Required for GenericContentManager soft delete functionality

DO $$ 
BEGIN
    -- Only proceed if 'categories' table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories' AND table_schema = 'public') THEN

        -- Add deleted_at column if it doesn't exist (required for soft delete filtering)
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'categories' AND column_name = 'deleted_at') THEN
            ALTER TABLE public.categories ADD COLUMN deleted_at TIMESTAMPTZ;
        END IF;

        -- Add created_by column if it doesn't exist (for owner tracking)
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'categories' AND column_name = 'created_by') THEN
            ALTER TABLE public.categories ADD COLUMN created_by UUID REFERENCES auth.users(id);
        END IF;

        -- Add created_at column if it doesn't exist
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'categories' AND column_name = 'created_at') THEN
            ALTER TABLE public.categories ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();
        END IF;

        -- Add updated_at column if it doesn't exist
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'categories' AND column_name = 'updated_at') THEN
            ALTER TABLE public.categories ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
        END IF;

        -- Create index for soft delete queries
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_categories_deleted_at ON public.categories(deleted_at)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_categories_type ON public.categories(type)';
        
    END IF;
END $$;

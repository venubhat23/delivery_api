-- Fix for PostgreSQL error: column customers.pincode does not exist
-- This script adds the missing 'country' column to the customers table

-- Add the missing country column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'customers' AND column_name = 'country'
    ) THEN
        ALTER TABLE customers ADD COLUMN country VARCHAR(255);
        RAISE NOTICE 'Added country column to customers table';
    ELSE
        RAISE NOTICE 'Country column already exists in customers table';
    END IF;
END $$;

-- Verify the column was added
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'customers' 
  AND column_name IN ('pincode', 'country', 'city', 'state', 'postal_code')
ORDER BY column_name;
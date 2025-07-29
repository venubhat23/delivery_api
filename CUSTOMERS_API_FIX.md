# Customers API Error Fix

## Problem Description

The customers API endpoint `GET /api/v1/customers` is failing in production with the following error:

```
PG::UndefinedColumn: ERROR: column customers.pincode does not exist
LINE 1: ... t0_r23, "customers"."password_digest" AS t0_r24, "customers...
```

## Root Cause Analysis

1. **Missing Database Migration**: The production database is missing recent migrations that add new columns to the `customers` table.

2. **Columns Added in Development**: The schema.rb shows these columns exist:
   - `pincode` (string)
   - `landmark` (string) 
   - `city` (string)
   - `postal_code` (string)
   - `state` (string)

3. **Missing Country Column**: The Customer model validates a `country` field, but there's no migration or column for it in the database.

## Migration Files Found

The following migration files exist but may not have been run in production:

- `20250724172533_add_pincode_and_landmark_to_customers.rb`
- `20250724173016_add_city_to_customers.rb`
- `20250724173244_add_postal_code_to_customers.rb`
- `20250724173805_add_state_to_customers.rb`

## Solution

### Option 1: Run Rails Migrations (Recommended)

```bash
# In production environment
bundle exec rails db:migrate RAILS_ENV=production
```

### Option 2: Direct SQL Fix (If Rails not available)

Execute the SQL script `fix_customers_table.sql`:

```sql
-- Add missing country column
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
```

### Option 3: Run Individual Migration Commands

```sql
-- Add pincode column
ALTER TABLE customers ADD COLUMN pincode VARCHAR(255);

-- Add landmark column  
ALTER TABLE customers ADD COLUMN landmark VARCHAR(255);

-- Add city column
ALTER TABLE customers ADD COLUMN city VARCHAR(255);

-- Add postal_code column
ALTER TABLE customers ADD COLUMN postal_code VARCHAR(255);

-- Add state column
ALTER TABLE customers ADD COLUMN state VARCHAR(255);

-- Add country column (missing from migrations)
ALTER TABLE customers ADD COLUMN country VARCHAR(255);
```

## Files Created/Modified

1. **New Migration**: `db/migrate/20250729120000_add_country_to_customers.rb`
   - Adds the missing `country` column

2. **SQL Fix Script**: `fix_customers_table.sql`
   - Direct SQL commands to add missing columns

## Verification Steps

After applying the fix:

1. **Check column exists**:
   ```sql
   SELECT column_name, data_type, is_nullable 
   FROM information_schema.columns 
   WHERE table_name = 'customers' 
     AND column_name IN ('pincode', 'country', 'city', 'state', 'postal_code')
   ORDER BY column_name;
   ```

2. **Test the API endpoint**:
   ```bash
   curl -X GET "{{base_url}}/api/v1/customers" \
        -H "Authorization: Bearer YOUR_TOKEN"
   ```

## Prevention

To prevent this issue in the future:

1. **Always run migrations in production** after deploying new code
2. **Check migration status** before deployment:
   ```bash
   bundle exec rails db:migrate:status RAILS_ENV=production
   ```
3. **Use database change management** tools or CI/CD pipelines that automatically run migrations

## Customer Model Validations

The Customer model has these validations that require the new columns:

```ruby
validates :city, presence: true, if: :address_api_context?
validates :state, presence: true, if: :address_api_context?
validates :postal_code, presence: true, if: :address_api_context?
validates :country, presence: true, if: :address_api_context?
```

These validations are conditional based on `address_api_context?` so they won't break existing functionality, but the columns must exist in the database for ActiveRecord to function properly.
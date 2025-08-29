#!/bin/bash

# Customers API Database Fix Deployment Script
# This script fixes the missing columns error in the customers table

set -e  # Exit on any error

echo "🔧 Starting Customers API Database Fix..."

# Check if we're in a Rails environment
if [ -f "Gemfile" ] && [ -f "config/application.rb" ]; then
    echo "✅ Rails application detected"
    
    # Option 1: Try to run Rails migrations (preferred)
    echo "🚀 Attempting to run Rails migrations..."
    if command -v bundle &> /dev/null; then
        echo "📦 Running bundle exec rails db:migrate..."
        bundle exec rails db:migrate RAILS_ENV=production || {
            echo "⚠️  Rails migration failed, falling back to SQL approach"
            USE_SQL=true
        }
    else
        echo "⚠️  Bundle not found, falling back to SQL approach"
        USE_SQL=true
    fi
else
    echo "⚠️  Not a Rails application, using SQL approach"
    USE_SQL=true
fi

# Option 2: Direct SQL execution (fallback)
if [ "$USE_SQL" = true ]; then
    echo "🗄️  Applying SQL fixes directly..."
    
    # Check if PostgreSQL client is available
    if command -v psql &> /dev/null; then
        echo "📊 PostgreSQL client found"
        
        # Prompt for database connection details
        read -p "Enter database host (default: localhost): " DB_HOST
        DB_HOST=${DB_HOST:-localhost}
        
        read -p "Enter database name: " DB_NAME
        read -p "Enter database user: " DB_USER
        
        echo "🔗 Connecting to database and applying fixes..."
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f fix_customers_table.sql
        
    else
        echo "❌ PostgreSQL client (psql) not found"
        echo "📋 Please run the following SQL commands manually in your database:"
        echo ""
        cat fix_customers_table.sql
        echo ""
        exit 1
    fi
fi

echo "✅ Database fix completed successfully!"

# Verification step
echo "🔍 Verifying the fix..."
if [ "$USE_SQL" != true ] && command -v bundle &> /dev/null; then
    echo "🧪 Testing Rails console connection..."
    bundle exec rails runner "puts Customer.column_names.select { |c| %w[pincode country city state postal_code].include?(c) }" RAILS_ENV=production
else
    echo "📝 Manual verification required. Please check that these columns exist in the customers table:"
    echo "   - pincode"
    echo "   - country" 
    echo "   - city"
    echo "   - state"
    echo "   - postal_code"
fi

echo ""
echo "🎉 Fix deployment complete!"
echo "💡 You can now test the API endpoint: GET /api/v1/customers"
echo ""
echo "📚 For more details, see CUSTOMERS_API_FIX.md"
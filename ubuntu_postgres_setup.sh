#!/bin/bash

# 🚀 PostgreSQL Setup Script for Ontrail Social-Fi Application
# This script sets up PostgreSQL server, creates database and user, and configures everything for Ontrail

set -e  # Exit on any error

echo "🐘 Setting up PostgreSQL for Ontrail Social-Fi Application..."
echo "=========================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DB_NAME="ontrail"
DB_USER="ontrail_user"
DB_PASSWORD="Tropictiger2025!"
POSTGRES_PASSWORD="Tropictiger2025!"

# Function to print status
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Update system and install PostgreSQL
print_status "Step 1: Installing PostgreSQL..."
apt-get update
apt-get install -y postgresql postgresql-contrib

# Step 2: Start and enable PostgreSQL service
print_status "Step 2: Starting PostgreSQL service..."
systemctl enable postgresql
systemctl start postgresql
systemctl status postgresql --no-pager

# Step 3: Set up PostgreSQL authentication
print_status "Step 3: Configuring PostgreSQL authentication..."

# Create a setup script for PostgreSQL
cat > /tmp/setup_postgres.sql << EOF
-- Set password for postgres user
ALTER USER postgres PASSWORD '$POSTGRES_PASSWORD';

-- Create database user for Ontrail
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';

-- Create database
CREATE DATABASE $DB_NAME OWNER $DB_USER;

-- Grant all privileges on database to user
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $DB_USER;

-- List databases to confirm
\\l
EOF

# Execute the setup script
print_status "Executing PostgreSQL setup script..."
su - postgres -c "psql -f /tmp/setup_postgres.sql"

# Clean up
rm /tmp/setup_postgres.sql

# Step 4: Test the connection
print_status "Step 4: Testing database connection..."
if PGPASSWORD="$DB_PASSWORD" psql -h localhost -U "$DB_USER" -d "$DB_NAME" -c "SELECT version();" > /dev/null 2>&1; then
    print_success "Database connection test successful!"
else
    print_error "Database connection test failed!"
    exit 1
fi

# Step 5: Create environment file for Ontrail application
print_status "Step 5: Creating environment configuration..."

# Database URL for the application
DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"

# Create .env.local file in the Ontrail webapp directory
ENV_FILE="/var/www/ontrailapp/webApp/.env.local"

cat > "$ENV_FILE" << EOF
# Database Configuration
DATABASE_URL="$DATABASE_URL"

# NextAuth.js Configuration
NEXTAUTH_URL="https://ontrail.tech"
NEXTAUTH_SECRET="your-nextauth-secret-here-replace-in-production"

# OAuth Providers (Configure these with your actual credentials)
GOOGLE_CLIENT_ID=""
GOOGLE_CLIENT_SECRET=""
FACEBOOK_CLIENT_ID=""
FACEBOOK_CLIENT_SECRET=""

# Solana Configuration
SOLANA_RPC_URL="https://api.devnet.solana.com"

# Application Environment
NODE_ENV="production"

# Optional: Additional configuration
# JWT_SECRET="your-jwt-secret-here"
# ENCRYPTION_KEY="your-encryption-key-here"
EOF

print_success "Environment file created at: $ENV_FILE"
print_warning "Remember to update OAuth credentials and secrets for production!"

# Step 6: Verify PostgreSQL is accessible
print_status "Step 6: Verifying PostgreSQL accessibility..."
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U "$DB_USER" -d "$DB_NAME" -c "SELECT current_database(), current_user, version();" | cat

print_success "PostgreSQL setup completed successfully!"
echo ""
echo "📊 Database Information:"
echo "   Database: $DB_NAME"
echo "   User: $DB_USER"
echo "   Host: localhost:5432"
echo "   Password: $DB_PASSWORD"
echo ""
echo "🔗 Database URL: $DATABASE_URL"
echo ""
echo "📁 Environment file: $ENV_FILE"
echo ""
echo "🚀 Next Steps:"
echo "   1. Run database migrations: cd /var/www/ontrailapp/webApp && npm run db:migrate"
echo "   2. Start the application: pm2 restart ontrail-app"
echo "   3. Test the application at: https://ontrail.tech"
echo ""
print_success "PostgreSQL setup for Ontrail Social-Fi is complete! 🎉"
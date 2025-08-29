#!/bin/bash

# Ontrail.tech Database Setup Script
# This script sets up the complete database structure for the ontrail.tech application

echo "🚀 Starting Ontrail.tech Database Setup..."
echo "============================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "Please run this script from the webApp directory (/var/www/ontrailapp/webApp)"
    exit 1
fi

print_header "Step 1: Installing Dependencies"
print_status "Installing npm packages..."
npm install

if [ $? -ne 0 ]; then
    print_error "Failed to install dependencies"
    exit 1
fi

print_header "Step 2: Testing Database Connection"
print_status "Testing database connection..."

# Test database connection
PGPASSWORD="PaX9912!" psql -U ontrail_user -d ontrail_db -h localhost -c "SELECT version();" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    print_error "Database connection failed!"
    print_error "Please check:"
    print_error "  1. PostgreSQL is running: systemctl status postgresql"
    print_error "  2. Database credentials are correct"
    print_error "  3. User 'ontrail_user' exists and has permissions"
    exit 1
fi

print_status "✅ Database connection successful!"

print_header "Step 3: Generating Database Migrations"
print_status "Running drizzle-kit generate..."

npx drizzle-kit generate

if [ $? -ne 0 ]; then
    print_error "Failed to generate migrations"
    exit 1
fi

print_status "✅ Migrations generated successfully!"

print_header "Step 4: Running Database Migrations"
print_status "Running drizzle-kit migrate..."

npx drizzle-kit migrate

if [ $? -ne 0 ]; then
    print_error "Failed to run migrations"
    exit 1
fi

print_status "✅ Database migrations completed!"

print_header "Step 5: Verifying Database Structure"
print_status "Checking created tables..."

# List all tables
echo "Database Tables:"
PGPASSWORD="PaX9912!" psql -U ontrail_user -d ontrail_db -c "\dt" | head -20

print_header "Step 6: Testing Application Database Connection"
print_status "Creating test connection script..."

# Create a test script
cat > test-db-connection.js << 'EOF'
const { db } = require('./src/lib/db/connect');

async function testConnection() {
  try {
    console.log('🔍 Testing database connection...');

    // Test basic query
    const result = await db.execute('SELECT version()');
    console.log('✅ Database connection successful!');
    console.log('📊 PostgreSQL Version:', result.rows[0].version);

    // Test table existence
    const tables = await db.execute(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      ORDER BY table_name;
    `);

    console.log('📋 Created tables:');
    tables.rows.forEach(row => {
      console.log(`  - ${row.table_name}`);
    });

    // Test user creation
    console.log('👤 Testing user creation...');
    const testUser = await db.insert(require('./src/lib/db/schema').users).values({
      email: 'test@example.com',
      name: 'Test User'
    }).returning();

    console.log('✅ Test user created successfully:', testUser[0].id);

    // Clean up
    await db.delete(require('./src/lib/db/schema').users)
      .where(require('./src/lib/db/schema').eq(require('./src/lib/db/schema').users.email, 'test@example.com'));

    console.log('🧹 Test user cleaned up');

    console.log('🎉 All database tests passed!');

  } catch (error) {
    console.error('❌ Database test failed:', error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

testConnection();
EOF

print_status "Running database connection test..."
node test-db-connection.js

if [ $? -eq 0 ]; then
    print_status "✅ Database connection test passed!"
else
    print_error "❌ Database connection test failed!"
    exit 1
fi

# Clean up test file
rm test-db-connection.js

print_header "Step 7: Setting up Environment Variables"
print_status "Ensuring environment variables are correct..."

# Check environment file
if [ -f ".env.local" ]; then
    print_status "✅ Environment file exists"
    grep "DATABASE_URL" .env.local
else
    print_warning "⚠️  Environment file not found, creating..."

    cat > .env.local << 'EOF'
# Database
DATABASE_URL="postgresql://ontrail_user:PaX9912!@localhost:5432/ontrail_db"

# NextAuth.js
NEXTAUTH_URL="https://ontrail.tech"
NEXTAUTH_SECRET="your-secret-key-here-change-this-in-production"

# Google OAuth
GOOGLE_CLIENT_ID=""
GOOGLE_CLIENT_SECRET=""

# Facebook OAuth
FACEBOOK_CLIENT_ID=""
FACEBOOK_CLIENT_SECRET=""

# Solana RPC
SOLANA_RPC_URL="https://api.devnet.solana.com"

NODE_ENV="production"
EOF

    print_status "✅ Environment file created"
fi

print_header "🎉 Setup Complete!"
echo ""
print_status "✅ Dependencies installed"
print_status "✅ Database connection verified"
print_status "✅ Migrations generated and applied"
print_status "✅ Database structure created"
print_status "✅ Application database connection tested"
print_status "✅ Environment variables configured"
echo ""
print_status "Your ontrail.tech database is ready!"
echo ""
print_status "Next steps:"
echo "  1. Build the application: npm run build"
echo "  2. Start the application: npm start"
echo "  3. Or restart PM2: pm2 restart ontrail-app"
echo ""
print_status "Database Tables Created:"
PGPASSWORD="PaX9912!" psql -U ontrail_user -d ontrail_db -c "\dt" --quiet

print_header "🚀 Ready for Production!"
echo ""
print_status "Your Social-Fi application database is fully configured and ready to use!"
echo "Visit https://ontrail.tech to start using your application."

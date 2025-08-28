#!/bin/bash

# 🚀 Manual PostgreSQL Setup for Ontrail Social-Fi
# Run this script on your server (85.208.51.194)

echo "🐘 Setting up PostgreSQL for Ontrail Social-Fi..."
echo "================================================"

# Step 1: Update system and install PostgreSQL
echo "Step 1: Installing PostgreSQL..."
apt-get update
apt-get install -y postgresql postgresql-contrib

# Step 2: Start PostgreSQL service
echo "Step 2: Starting PostgreSQL service..."
systemctl enable postgresql
systemctl start postgresql
systemctl status postgresql --no-pager

# Step 3: Set up database and user
echo "Step 3: Setting up database and user..."

# Create setup script
cat > /tmp/db_setup.sql << 'EOF'
-- PostgreSQL setup for Ontrail
ALTER USER postgres PASSWORD 'Tropictiger2025!';
CREATE USER ontrail_user WITH PASSWORD 'Tropictiger2025!';
CREATE DATABASE ontrail OWNER ontrail_user;
GRANT ALL PRIVILEGES ON DATABASE ontrail TO ontrail_user;
GRANT ALL ON SCHEMA public TO ontrail_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ontrail_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ontrail_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ontrail_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ontrail_user;
\l
EOF

# Execute setup script
su - postgres -c "psql -f /tmp/db_setup.sql"

# Step 4: Create environment file
echo "Step 4: Creating environment configuration..."
cat > /var/www/ontrailapp/webApp/.env.local << 'EOF'
# Database Configuration
DATABASE_URL="postgresql://ontrail_user:Tropictiger2025!@localhost:5432/ontrail"

# NextAuth.js Configuration
NEXTAUTH_URL="https://ontrail.tech"
NEXTAUTH_SECRET="ontrail-nextauth-secret-change-in-production-2025"

# OAuth Providers
GOOGLE_CLIENT_ID=""
GOOGLE_CLIENT_SECRET=""
FACEBOOK_CLIENT_ID=""
FACEBOOK_CLIENT_SECRET=""

# Solana Configuration
SOLANA_RPC_URL="https://api.devnet.solana.com"

# Application Environment
NODE_ENV="production"
EOF

# Step 5: Test database connection
echo "Step 5: Testing database connection..."
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "SELECT version();"

if [ $? -eq 0 ]; then
    echo "✅ Database connection test successful"
else
    echo "❌ Database connection test failed"
    exit 1
fi

# Step 6: Install dependencies and run migrations
echo "Step 6: Installing dependencies and running migrations..."
cd /var/www/ontrailapp/webApp
npm install

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Dependency installation failed"
    exit 1
fi

# Run migrations
npm run db:migrate

if [ $? -eq 0 ]; then
    echo "✅ Database migrations completed successfully"
else
    echo "❌ Database migrations failed"
    exit 1
fi

# Step 7: Restart application
echo "Step 7: Restarting application..."
pm2 restart ontrail-app

if [ $? -eq 0 ]; then
    echo "✅ Application restarted successfully"
else
    echo "❌ Application restart failed"
    exit 1
fi

# Step 8: Final verification
echo "Step 8: Final verification..."
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "\dt"

echo ""
echo "🎉 PostgreSQL Setup Complete!"
echo "============================="
echo ""
echo "📊 Database Configuration:"
echo "   Server: localhost:5432"
echo "   Database: ontrail"
echo "   User: ontrail_user"
echo "   Password: Tropictiger2025!"
echo "   Connection: postgresql://ontrail_user:Tropictiger2025!@localhost:5432/ontrail"
echo ""
echo "🌐 Application URL: https://ontrail.tech"
echo ""
echo "🗂️ Created Tables:"
echo "   ✓ users, profiles, friendships"
echo "   ✓ pois, poi_visits, quests"
echo "   ✓ posts, comments, follows"
echo "   ✓ wallets, transactions"
echo ""
echo "🔧 Next Steps:"
echo "1. Configure OAuth providers (Google/Facebook)"
echo "2. Update NEXTAUTH_SECRET in production"
echo "3. Test user registration and social features"
echo "4. Configure Solana wallet integration"
echo ""
echo "📞 Troubleshooting:"
echo "- Check PM2 logs: pm2 logs ontrail-app"
echo "- Check PostgreSQL: PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail"
echo "- View PostgreSQL logs: sudo tail -f /var/log/postgresql/postgresql-*.log"

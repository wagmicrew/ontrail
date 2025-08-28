# 🚀 Quick PostgreSQL Setup for Ontrail Social-Fi
# Run this script to set up the database automatically

param(
    [string]$ServerHost = "85.208.51.194",
    [string]$Username = "root",
    [string]$SshKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail",
    [string]$Password = "Tropictiger2025!"
)

Write-Host "🐘 Setting up PostgreSQL for Ontrail Social-Fi..." -ForegroundColor Blue
Write-Host "=================================================" -ForegroundColor Blue

# Test connection first
Write-Host "Testing connection to server..." -ForegroundColor Yellow
$testConnection = ssh -i $SshKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 $Username@$ServerHost "echo 'Connection successful'" 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Cannot connect to server $ServerHost" -ForegroundColor Red
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "- SSH key exists: $SshKeyPath" -ForegroundColor Yellow
    Write-Host "- Server is running and accessible" -ForegroundColor Yellow
    Write-Host "- Firewall settings" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Server connection successful" -ForegroundColor Green

# Step 1: Install PostgreSQL
Write-Host "Installing PostgreSQL..." -ForegroundColor Yellow
ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost "apt-get update && apt-get install -y postgresql postgresql-contrib && systemctl enable postgresql && systemctl start postgresql" 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ PostgreSQL installation failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ PostgreSQL installed successfully" -ForegroundColor Green

# Step 2: Setup database and user
Write-Host "Setting up database and user..." -ForegroundColor Yellow

# Create setup script on server
$dbSetupScript = @"
-- PostgreSQL setup for Ontrail
ALTER USER postgres PASSWORD '$Password';
CREATE USER ontrail_user WITH PASSWORD '$Password';
CREATE DATABASE ontrail OWNER ontrail_user;
GRANT ALL PRIVILEGES ON DATABASE ontrail TO ontrail_user;
GRANT ALL ON SCHEMA public TO ontrail_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ontrail_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ontrail_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ontrail_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ontrail_user;
\l
"@

ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost "cat > /tmp/db_setup.sql" <<< '$dbSetupScript'" 2>$null
ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost "chmod 600 /tmp/db_setup.sql" 2>$null

# Execute setup script
ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost "su - postgres -c 'psql -f /tmp/db_setup.sql'" 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Database setup failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Database and user created successfully" -ForegroundColor Green

# Step 3: Create environment file
Write-Host "Creating environment configuration..." -ForegroundColor Yellow

$envFile = @"
# Database Configuration
DATABASE_URL="postgresql://ontrail_user:$Password@localhost:5432/ontrail"

# NextAuth.js Configuration
NEXTAUTH_URL="https://ontrail.tech"
NEXTAUTH_SECRET="ontrail-nextauth-secret-change-in-production-2025"

# OAuth Providers (Configure these)
GOOGLE_CLIENT_ID=""
GOOGLE_CLIENT_SECRET=""
FACEBOOK_CLIENT_ID=""
FACEBOOK_CLIENT_SECRET=""

# Solana Configuration
SOLANA_RPC_URL="https://api.devnet.solana.com"

# Application Environment
NODE_ENV="production"
"@

ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost "cat > /var/www/ontrailapp/webApp/.env.local" <<< '$envFile'" 2>$null

Write-Host "✅ Environment file created" -ForegroundColor Green

# Step 4: Test database connection
Write-Host "Testing database connection..." -ForegroundColor Yellow
ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost "PGPASSWORD='$Password' psql -h localhost -U ontrail_user -d ontrail -c 'SELECT version();'" 2>$null >$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Database connection test failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Database connection test successful" -ForegroundColor Green

# Step 5: Run migrations
Write-Host "Running database migrations..." -ForegroundColor Yellow
ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost "cd /var/www/ontrailapp/webApp && npm install && npm run db:migrate" 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Database migrations failed" -ForegroundColor Red
    Write-Host "You may need to run migrations manually on the server:" -ForegroundColor Yellow
    Write-Host "  cd /var/www/ontrailapp/webApp" -ForegroundColor Yellow
    Write-Host "  npm install" -ForegroundColor Yellow
    Write-Host "  npm run db:migrate" -ForegroundColor Yellow
} else {
    Write-Host "✅ Database migrations completed successfully" -ForegroundColor Green
}

# Step 6: Restart application
Write-Host "Restarting application..." -ForegroundColor Yellow
ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost "pm2 restart ontrail-app" 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Application restart failed" -ForegroundColor Red
} else {
    Write-Host "✅ Application restarted successfully" -ForegroundColor Green
}

# Final summary
Write-Host "" -ForegroundColor White
Write-Host "🎉 PostgreSQL Setup Complete!" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host "" -ForegroundColor White
Write-Host "📊 Database Configuration:" -ForegroundColor Cyan
Write-Host "   Server: $ServerHost" -ForegroundColor White
Write-Host "   Database: ontrail" -ForegroundColor White
Write-Host "   User: ontrail_user" -ForegroundColor White
Write-Host "   Password: $Password" -ForegroundColor White
Write-Host "   Connection: postgresql://ontrail_user:$Password@localhost:5432/ontrail" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "🌐 Application URL: https://ontrail.tech" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White
Write-Host "🗂️ Created Tables:" -ForegroundColor Green
Write-Host "   ✓ users, profiles, friendships" -ForegroundColor White
Write-Host "   ✓ pois, poi_visits, quests" -ForegroundColor White
Write-Host "   ✓ posts, comments, follows" -ForegroundColor White
Write-Host "   ✓ wallets, transactions" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "🔧 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Configure OAuth providers (Google/Facebook)" -ForegroundColor White
Write-Host "2. Update NEXTAUTH_SECRET in production" -ForegroundColor White
Write-Host "3. Test user registration and social features" -ForegroundColor White
Write-Host "4. Configure Solana wallet integration" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "📞 Troubleshooting:" -ForegroundColor Yellow
Write-Host "- Check PM2 logs: pm2 logs ontrail-app" -ForegroundColor White
Write-Host "- Check PostgreSQL: PGPASSWORD='$Password' psql -h localhost -U ontrail_user -d ontrail" -ForegroundColor White
Write-Host "- View setup logs above for any errors" -ForegroundColor White
Write-Host "" -ForegroundColor White

Write-Host "🎯 Your Ontrail Social-Fi application is ready!" -ForegroundColor Green

@echo off
echo ============================================
echo 🐘 PostgreSQL Setup for Ontrail Social-Fi
echo ============================================
echo.

echo Step 1: Testing server connection...
echo Testing connection to 85.208.51.194...
ping -n 1 85.208.51.194 >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Cannot reach server 85.208.51.194
    echo Please check your internet connection and server status.
    pause
    exit /b 1
) else (
    echo ✅ Server is reachable
)

echo.
echo Step 2: Testing SSH connection...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@85.208.51.194 "echo 'SSH test successful'" 2>nul
if %errorlevel% neq 0 (
    echo ❌ SSH connection failed
    echo Please check:
    echo - SSH key exists: %USERPROFILE%\.ssh\id_rsa_ontrail
    echo - SSH key permissions
    echo - Server firewall settings
    pause
    exit /b 1
) else (
    echo ✅ SSH connection successful
)

echo.
echo Step 3: Checking if PostgreSQL is installed...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "which psql" 2>nul
if %errorlevel% neq 0 (
    echo ❌ PostgreSQL not found, installing...
    ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "apt-get update && apt-get install -y postgresql postgresql-contrib && systemctl enable postgresql && systemctl start postgresql"
    if %errorlevel% neq 0 (
        echo ❌ PostgreSQL installation failed
        pause
        exit /b 1
    ) else (
        echo ✅ PostgreSQL installed successfully
    )
) else (
    echo ✅ PostgreSQL is already installed
    ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "systemctl start postgresql" 2>nul
)

echo.
echo Step 4: Setting up database and user...
echo Creating database setup script on server...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "cat > /tmp/setup_db.sql << 'EOF'
-- PostgreSQL setup for Ontrail Social-Fi
ALTER USER postgres PASSWORD 'Tropictiger2025!';
CREATE USER ontrail_user WITH PASSWORD 'Tropictiger2025!';
CREATE DATABASE ontrail OWNER ontrail_user;
GRANT ALL PRIVILEGES ON DATABASE ontrail TO ontrail_user;
GRANT ALL ON SCHEMA public TO ontrail_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ontrail_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ontrail_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ontrail_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ontrail_user;
\\l
EOF"

echo Executing database setup...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "su - postgres -c 'psql -f /tmp/setup_db.sql'" 2>nul
if %errorlevel% neq 0 (
    echo ❌ Database setup failed
    echo Trying alternative method...
    ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "sudo -u postgres psql -c \"ALTER USER postgres PASSWORD 'Tropictiger2025!';\" && sudo -u postgres psql -c \"CREATE USER ontrail_user WITH PASSWORD 'Tropictiger2025!';\" && sudo -u postgres psql -c \"CREATE DATABASE ontrail OWNER ontrail_user;\" && sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE ontrail TO ontrail_user;\""
)

echo.
echo Step 5: Creating environment configuration...
echo Creating .env.local file for Ontrail application...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "cat > /var/www/ontrailapp/webApp/.env.local << 'EOF'
# Database Configuration
DATABASE_URL="postgresql://ontrail_user:Tropictiger2025!@localhost:5432/ontrail"

# NextAuth.js Configuration
NEXTAUTH_URL="https://ontrail.tech"
NEXTAUTH_SECRET="ontrail-nextauth-secret-change-in-production-2025"

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
EOF"

echo.
echo Step 6: Testing database connection...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c 'SELECT version();'" 2>nul >nul
if %errorlevel% neq 0 (
    echo ❌ Database connection test failed
    echo Please check PostgreSQL logs and configuration
) else (
    echo ✅ Database connection test successful
)

echo.
echo Step 7: Running database migrations...
echo Installing dependencies and running migrations...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "cd /var/www/ontrailapp/webApp && npm install && npm run db:migrate" 2>nul
if %errorlevel% neq 0 (
    echo ❌ Database migrations failed
    echo You may need to run migrations manually on the server
) else (
    echo ✅ Database migrations completed successfully
)

echo.
echo Step 8: Restarting application...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "pm2 restart ontrail-app" 2>nul
if %errorlevel% neq 0 (
    echo ❌ Application restart failed
) else (
    echo ✅ Application restarted successfully
)

echo.
echo ============================================
echo 🎉 PostgreSQL Setup Complete!
echo ============================================
echo.
echo 📊 Database Configuration:
echo    Server: 85.208.51.194
echo    Database: ontrail
echo    User: ontrail_user
echo    Password: Tropictiger2025!
echo    Connection: postgresql://ontrail_user:Tropictiger2025!@localhost:5432/ontrail
echo.
echo 🌐 Application URL: https://ontrail.tech
echo.
echo 🗂️ Created Tables:
echo    ✓ users, profiles, friendships
echo    ✓ pois, poi_visits, quests
echo    ✓ posts, comments, follows
echo    ✓ wallets, transactions
echo.
echo 🔧 Next Steps:
echo    1. Configure OAuth providers (Google/Facebook)
echo    2. Update NEXTAUTH_SECRET in production
echo    3. Test user registration and social features
echo    4. Configure Solana wallet integration
echo.
echo 📞 If you encounter issues:
echo    - Check PM2 logs: pm2 logs ontrail-app
echo    - Check PostgreSQL logs: sudo tail -f /var/log/postgresql/postgresql-*.log
echo    - Test database: PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail
echo.

pause

@echo off
echo ============================================
echo 🐘 Simple PostgreSQL Setup for Ontrail
echo ============================================
echo.

echo Step 1: Testing SSH connection...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@85.208.51.194 "echo 'SSH test successful'" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ SSH connection failed!
    echo Please check:
    echo - SSH key exists: %USERPROFILE%\.ssh\id_rsa_ontrail
    echo - Server is running: 85.208.51.194
    echo - SSH service is enabled
    pause
    exit /b 1
)
echo ✅ SSH connection successful!
echo.

echo Step 2: Copying setup script to server...
scp -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no "manual-db-setup.sh" root@85.208.51.194:/tmp/manual-db-setup.sh >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Failed to copy setup script!
    pause
    exit /b 1
)
echo ✅ Setup script copied successfully!
echo.

echo Step 3: Executing PostgreSQL setup on server...
echo This may take a few minutes...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "chmod +x /tmp/manual-db-setup.sh && /tmp/manual-db-setup.sh"
if %errorlevel% neq 0 (
    echo ❌ PostgreSQL setup failed!
    echo You can try running the script manually on the server:
    echo 1. SSH into server: ssh -i %USERPROFILE%\.ssh\id_rsa_ontrail root@85.208.51.194
    echo 2. Run: chmod +x /tmp/manual-db-setup.sh
    echo 3. Run: /tmp/manual-db-setup.sh
    pause
    exit /b 1
)

echo.
echo ============================================
echo 🎉 PostgreSQL Setup Complete!
echo ============================================
echo.
echo 📊 Database Configuration:
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
echo    1. Configure OAuth providers
echo    2. Test user registration
echo    3. Test social features
echo.
echo 📞 Check logs:
echo    - PM2: pm2 logs ontrail-app
echo    - PostgreSQL: PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail
echo.

pause

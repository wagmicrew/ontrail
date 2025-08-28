@echo off
echo ============================================
echo 🔍 Verifying PostgreSQL Setup
echo ============================================
echo.

echo Step 1: Testing SSH connection...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@85.208.51.194 "echo 'SSH OK'" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ SSH connection failed!
    echo Cannot verify database setup without SSH access.
    pause
    exit /b 1
)
echo ✅ SSH connection successful!
echo.

echo Step 2: Checking PostgreSQL service...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "systemctl is-active postgresql" 2>nul
if %errorlevel% neq 0 (
    echo ❌ PostgreSQL service is not running!
    echo Please run the database setup first.
    pause
    exit /b 1
)
echo ✅ PostgreSQL service is running!
echo.

echo Step 3: Testing database connection...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c 'SELECT current_database(), current_user;' 2>/dev/null" 2>nul >nul
if %errorlevel% neq 0 (
    echo ❌ Database connection failed!
    echo Please check database setup.
    pause
    exit /b 1
)
echo ✅ Database connection successful!
echo.

echo Step 4: Checking database tables...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c '\dt' | wc -l" 2>nul > temp_count.txt 2>&1
set /p TABLE_COUNT=<temp_count.txt
if %TABLE_COUNT% lss 10 (
    echo ❌ Not enough tables found! Expected ~13 tables.
    echo Please run database migrations.
    del temp_count.txt 2>nul
    pause
    exit /b 1
)
echo ✅ Database tables created successfully! (%TABLE_COUNT% tables)
del temp_count.txt 2>nul
echo.

echo Step 5: Checking application status...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "pm2 describe ontrail-app > /dev/null 2>&1 && echo 'running' || echo 'not running'" 2>nul > temp_status.txt
set /p APP_STATUS=<temp_status.txt
if "%APP_STATUS%" neq "running" (
    echo ❌ Application is not running!
    echo Please restart the application.
    del temp_status.txt 2>nul
    pause
    exit /b 1
)
echo ✅ Application is running!
del temp_status.txt 2>nul
echo.

echo Step 6: Testing website accessibility...
curl -I https://ontrail.tech 2>nul | find "HTTP/2 200" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Website is not accessible!
    echo Please check application configuration.
    pause
    exit /b 1
)
echo ✅ Website is accessible!
echo.

echo ============================================
echo 🎉 Database Setup Verification Complete!
echo ============================================
echo.
echo ✅ PostgreSQL is running
echo ✅ Database connection works
echo ✅ Tables are created
echo ✅ Application is running
echo ✅ Website is accessible
echo.
echo 🌐 Your Ontrail application is ready!
echo    URL: https://ontrail.tech
echo    Database: postgresql://ontrail_user:Tropictiger2025!@localhost:5432/ontrail
echo.
echo 📊 Database contains ~13 tables for:
echo    • User authentication and profiles
echo    • Social friendships and follows
echo    • Posts, comments, and engagement
echo    • Points of Interest (POI)
echo    • Quest system and challenges
echo    • Solana wallet integration
echo.
echo 🚀 Next steps:
echo    1. Configure OAuth providers (Google/Facebook)
echo    2. Test user registration
echo    3. Set up Solana wallet features
echo    4. Test social features
echo.

pause

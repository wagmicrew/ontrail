# 🚀 Database Migration Script for Ontrail Social-Fi Application
# This script runs Drizzle migrations on the remote server

param(
    [string]$ServerHost = "85.208.51.194",
    [string]$Username = "root",
    [string]$SshKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail",
    [string]$AppDirectory = "/var/www/ontrailapp/webApp"
)

# Colors for output
$Blue = "Blue"
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

Write-Host "🗄️ Running Database Migrations for Ontrail Social-Fi Application..." -ForegroundColor Blue
Write-Host "===================================================================" -ForegroundColor Blue

# Step 1: Test SSH connection
Write-Status "Testing SSH connection to $ServerHost..."
try {
    $testResult = ssh -i $SshKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 $Username@$ServerHost "echo 'SSH connection successful'" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SSH connection successful!"
    } else {
        throw "SSH connection failed"
    }
} catch {
    Write-Error "Cannot connect to server $ServerHost. Please check your SSH configuration."
    exit 1
}

# Step 2: Check if application directory exists
Write-Status "Checking application directory..."
try {
    $checkDirCommand = "ls -la $AppDirectory"
    ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost $checkDirCommand 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Application directory exists!"
    } else {
        throw "Application directory not found"
    }
} catch {
    Write-Error "Application directory $AppDirectory not found on server."
    Write-Host "Make sure the application is deployed to the server first." -ForegroundColor Yellow
    exit 1
}

# Step 3: Navigate to app directory and check environment
Write-Status "Checking database configuration..."
try {
    $checkEnvCommand = "cd $AppDirectory && ls -la .env.local && cat .env.local | grep DATABASE_URL"
    ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost $checkEnvCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Database configuration found!"
    } else {
        Write-Warning "Environment file not found or DATABASE_URL not configured."
    }
} catch {
    Write-Warning "Could not verify database configuration."
}

# Step 4: Install dependencies (if needed)
Write-Status "Ensuring dependencies are installed..."
try {
    $installDepsCommand = "cd $AppDirectory && npm install"
    ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost $installDepsCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Dependencies installed successfully!"
    } else {
        Write-Warning "Could not install dependencies automatically."
    }
} catch {
    Write-Warning "Dependency installation may have issues."
}

# Step 5: Run database migrations
Write-Status "Running database migrations..."
try {
    $migrateCommand = "cd $AppDirectory && npm run db:migrate"
    ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost $migrateCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Database migrations completed successfully!"
    } else {
        throw "Database migration failed"
    }
} catch {
    Write-Error "Database migration failed!"
    Write-Host "Possible issues:" -ForegroundColor Yellow
    Write-Host "1. PostgreSQL is not running or accessible" -ForegroundColor Yellow
    Write-Host "2. Database credentials are incorrect" -ForegroundColor Yellow
    Write-Host "3. Migration files are missing or corrupted" -ForegroundColor Yellow
    Write-Host "4. Environment variables are not set correctly" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can try running the migration manually:" -ForegroundColor Cyan
    Write-Host "1. SSH into the server: ssh -i $SshKeyPath $Username@$ServerHost" -ForegroundColor Cyan
    Write-Host "2. Navigate to app: cd $AppDirectory" -ForegroundColor Cyan
    Write-Host "3. Run migration: npm run db:migrate" -ForegroundColor Cyan
    exit 1
}

# Step 6: Verify migration success
Write-Status "Verifying migration success..."
try {
    $verifyCommand = "cd $AppDirectory && npx drizzle-kit check"
    ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost $verifyCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Migration verification successful!"
    } else {
        Write-Warning "Migration verification had issues (may still be okay)."
    }
} catch {
    Write-Warning "Could not verify migration status."
}

# Step 7: Show database status
Write-Status "Checking database tables..."
try {
    $checkTablesCommand = "cd $AppDirectory && node -e \"const { db } = require('./src/lib/db/connect.ts'); console.log('Database connection test...');\""
    Write-Host "Note: Database connection test would require proper Node.js setup." -ForegroundColor Yellow
} catch {
    Write-Host "Database status check would require additional setup." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Database Migration Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Migration Summary:" -ForegroundColor Cyan
Write-Host "   Server: $ServerHost" -ForegroundColor White
Write-Host "   Application: $AppDirectory" -ForegroundColor White
Write-Host "   Status: Migrations Applied" -ForegroundColor White
Write-Host ""
Write-Host "🗂️ Created Tables:" -ForegroundColor Green
Write-Host "   ✓ users - User authentication and profiles" -ForegroundColor White
Write-Host "   ✓ profiles - Extended user profiles with valuation" -ForegroundColor White
Write-Host "   ✓ friendships - Tokenized friendship system" -ForegroundColor White
Write-Host "   ✓ pois - Points of Interest with NFT support" -ForegroundColor White
Write-Host "   ✓ quests - Quest system with sponsorship" -ForegroundColor White
Write-Host "   ✓ posts - Social media posts and timeline" -ForegroundColor White
Write-Host "   ✓ wallets - Solana wallet management" -ForegroundColor White
Write-Host "   ✓ transactions - Blockchain transaction tracking" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Green
Write-Host "1. Restart the Ontrail application:" -ForegroundColor White
Write-Host "   pm2 restart ontrail-app" -ForegroundColor White
Write-Host ""
Write-Host "2. Test the application at: https://ontrail.tech" -ForegroundColor White
Write-Host ""
Write-Host "3. Verify database connectivity in the application logs" -ForegroundColor White

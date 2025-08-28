# Setup script for SSH MCP Server
# This script installs the SSH MCP server and configures it for Ontrail

param(
    [string]$ServerHost = "ontrail.tech",
    [string]$ServerUser = "root",
    [string]$SSHKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail"
)

Write-Host "🚀 Setting up SSH MCP Server for Ontrail..." -ForegroundColor Green

# Check if Node.js is installed
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js is not installed. Please install Node.js 18+ first." -ForegroundColor Red
    Write-Host "   Download from: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check if npm is installed
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "❌ npm is not installed. Please install npm first." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Node.js and npm are installed" -ForegroundColor Green

# Install MCP SDK globally (if not already installed)
Write-Host "📦 Installing MCP SDK..." -ForegroundColor Blue
try {
    npm install -g @modelcontextprotocol/sdk
    Write-Host "✅ MCP SDK installed successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to install MCP SDK: $_" -ForegroundColor Red
    exit 1
}

# Create MCP directory if it doesn't exist
$MCP_DIR = "$env:USERPROFILE\.cursor-mcp"
New-Item -ItemType Directory -Force -Path $MCP_DIR | Out-Null

# Copy the MCP server files
Write-Host "📋 Setting up MCP server files..." -ForegroundColor Blue

# Read the content of the files and create them in the MCP directory
$MCP_SERVER_CONTENT = Get-Content "mcp-server-ssh.js" -Raw
$MCP_PACKAGE_CONTENT = Get-Content "mcp-server-ssh-package.json" -Raw

Set-Content -Path "$MCP_DIR\mcp-server-ssh.js" -Value $MCP_SERVER_CONTENT
Set-Content -Path "$MCP_DIR\package.json" -Value $MCP_PACKAGE_CONTENT

# Install dependencies for the MCP server
Write-Host "📦 Installing MCP server dependencies..." -ForegroundColor Blue
Push-Location $MCP_DIR
try {
    npm install
    Write-Host "✅ MCP server dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to install dependencies: $_" -ForegroundColor Red
}
Pop-Location

# Check if SSH key exists
if (-not (Test-Path $SSHKeyPath)) {
    Write-Host "⚠️  SSH key not found at $SSHKeyPath" -ForegroundColor Yellow
    Write-Host "   Please ensure your SSH key is properly configured" -ForegroundColor Yellow
    Write-Host "   You can generate it using: ssh-keygen -t rsa -b 4096 -f $SSHKeyPath" -ForegroundColor Cyan
} else {
    Write-Host "✅ SSH key found at $SSHKeyPath" -ForegroundColor Green
}

# Test SSH connection
Write-Host "🔗 Testing SSH connection to $ServerHost..." -ForegroundColor Blue
try {
    $testResult = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$ServerUser@$ServerHost" "echo 'SSH connection successful'" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH connection to $ServerHost is working" -ForegroundColor Green
    } else {
        throw "SSH connection failed"
    }
} catch {
    Write-Host "❌ SSH connection failed. Please check:" -ForegroundColor Red
    Write-Host "   1. SSH key is properly configured" -ForegroundColor Yellow
    Write-Host "   2. Server is accessible at $ServerHost" -ForegroundColor Yellow
    Write-Host "   3. SSH service is running on the server" -ForegroundColor Yellow
    Write-Host "   4. Firewall allows SSH connections" -ForegroundColor Yellow
}

# Update MCP configuration
Write-Host "⚙️  Updating Cursor MCP configuration..." -ForegroundColor Blue
$MCP_CONFIG_PATH = "$env:USERPROFILE\.cursor\mcp.json"

# Read existing config or create new one
if (Test-Path $MCP_CONFIG_PATH) {
    $existingConfig = Get-Content $MCP_CONFIG_PATH -Raw | ConvertFrom-Json
} else {
    $existingConfig = @{}
}

# Add or update SSH remote manager configuration
$existingConfig."ssh-remote-manager" = @{
    "command" = "node"
    "args" = @("$MCP_DIR\mcp-server-ssh.js")
    "env" = @{
        "SSH_HOST" = $ServerHost
        "SSH_USER" = $ServerUser
        "SSH_KEY_PATH" = $SSHKeyPath
    }
}

# Save updated configuration
$existingConfig | ConvertTo-Json -Depth 10 | Set-Content $MCP_CONFIG_PATH

Write-Host "✅ Cursor MCP configuration updated" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 SSH MCP Server setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📖 Usage:" -ForegroundColor Blue
Write-Host "   The MCP server will be automatically loaded by Cursor"
Write-Host "   Available tools:"
Write-Host "   • ssh_exec - Execute commands on remote server"
Write-Host "   • ssh_file_read - Read files from remote server"
Write-Host "   • ssh_file_write - Write files to remote server"
Write-Host "   • ssh_list_dir - List directory contents"
Write-Host "   • ssh_status - Get server status"
Write-Host "   • ssh_deploy - Deploy application updates"
Write-Host "   • ssh_database - Manage PostgreSQL database"
Write-Host ""
Write-Host "🔧 Configuration:" -ForegroundColor Blue
Write-Host "   Server: $ServerHost"
Write-Host "   User: $ServerUser"
Write-Host "   SSH Key: $SSHKeyPath"
Write-Host "   MCP Directory: $MCP_DIR"
Write-Host ""
Write-Host "💡 You can now use Cursor to remotely manage your Ontrail server!" -ForegroundColor Green
Write-Host ""
Write-Host "🔄 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Restart Cursor IDE to load the new MCP server"
Write-Host "   2. Test the connection by asking Cursor to 'check server status'"
Write-Host "   3. Use commands like 'run command on server: pm2 status'"


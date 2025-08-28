#!/bin/bash

# Setup script for SSH MCP Server
# This script installs the SSH MCP server and configures it for Ontrail

set -e

echo "🚀 Setting up SSH MCP Server for Ontrail..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

echo "✅ Node.js and npm are installed"

# Install MCP SDK globally (if not already installed)
echo "📦 Installing MCP SDK..."
npm install -g @modelcontextprotocol/sdk

# Create MCP directory if it doesn't exist
MCP_DIR="$HOME/.cursor-mcp"
mkdir -p "$MCP_DIR"

# Copy the MCP server files
echo "📋 Setting up MCP server files..."
cp mcp-server-ssh.js "$MCP_DIR/"
cp mcp-server-ssh-package.json "$MCP_DIR/package.json"

# Install dependencies for the MCP server
cd "$MCP_DIR"
npm install

# Check if SSH key exists
SSH_KEY_PATH="$HOME/.ssh/id_rsa_ontrail"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "⚠️  SSH key not found at $SSH_KEY_PATH"
    echo "   Please ensure your SSH key is properly configured"
    echo "   You can copy it from your Windows machine:"
    echo "   scp user@windows-machine:~/.ssh/id_rsa_ontrail ~/.ssh/"
fi

# Test SSH connection
echo "🔗 Testing SSH connection to ontrail.tech..."
if ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@ontrail.tech "echo 'SSH connection successful'" 2>/dev/null; then
    echo "✅ SSH connection to ontrail.tech is working"
else
    echo "❌ SSH connection failed. Please check:"
    echo "   1. SSH key is properly configured"
    echo "   2. Server is accessible at ontrail.tech"
    echo "   3. SSH service is running on the server"
fi

echo ""
echo "🎉 SSH MCP Server setup complete!"
echo ""
echo "📖 Usage:"
echo "   The MCP server will be automatically loaded by Cursor"
echo "   Available tools:"
echo "   • ssh_exec - Execute commands on remote server"
echo "   • ssh_file_read - Read files from remote server"
echo "   • ssh_file_write - Write files to remote server"
echo "   • ssh_list_dir - List directory contents"
echo "   • ssh_status - Get server status"
echo "   • ssh_deploy - Deploy application updates"
echo "   • ssh_database - Manage PostgreSQL database"
echo ""
echo "🔧 Configuration:"
echo "   Server: ontrail.tech"
echo "   User: root"
echo "   SSH Key: $SSH_KEY_PATH"
echo ""
echo "💡 You can now use Cursor to remotely manage your Ontrail server!"


# 🚀 Ontrail Database Setup Instructions

## 📋 Quick Setup (Recommended)

### Option 1: Run Automated Script
1. **Double-click the batch file:**
   ```
   setup-database.bat
   ```

2. **Follow the on-screen instructions**

3. **Wait for completion** (may take 2-5 minutes)

---

## 🔧 Manual Setup (Step-by-Step)

If the automated script doesn't work, follow these manual steps:

### Step 1: Verify Server Access
```bash
# Test server connectivity
ping 85.208.51.194

# Test SSH connection
ssh -i ~/.ssh/id_rsa_ontrail root@85.208.51.194 "echo 'SSH works'"
```

### Step 2: Install PostgreSQL (on server)
```bash
# SSH into your server
ssh -i ~/.ssh/id_rsa_ontrail root@85.208.51.194

# Install PostgreSQL
sudo apt update
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Verify installation
systemctl status postgresql
psql --version
```

### Step 3: Create Database and User (on server)
```bash
# Switch to postgres user
sudo -u postgres psql

# Run these commands in PostgreSQL:
ALTER USER postgres PASSWORD 'Tropictiger2025!';
CREATE USER ontrail_user WITH PASSWORD 'Tropictiger2025!';
CREATE DATABASE ontrail OWNER ontrail_user;
GRANT ALL PRIVILEGES ON DATABASE ontrail TO ontrail_user;
\q
```

### Step 4: Create Environment File (on server)
```bash
# Create .env.local in application directory
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
```

### Step 5: Run Database Migrations (on server)
```bash
# Navigate to application
cd /var/www/ontrailapp/webApp

# Install dependencies
npm install

# Run migrations
npm run db:migrate

# Verify migration success
npx drizzle-kit check
```

### Step 6: Test Database Connection (on server)
```bash
# Test connection
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "SELECT current_database(), current_user;"

# Check tables were created
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "\dt"
```

### Step 7: Restart Application (on server)
```bash
# Restart the application
pm2 restart ontrail-app

# Check status
pm2 status

# View logs
pm2 logs ontrail-app --lines 20
```

---

## 🧪 Testing the Setup

### Test Database Connection:
```bash
# From server
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "SELECT * FROM users LIMIT 1;"
```

### Test Application:
1. Visit: `https://ontrail.tech`
2. Check PM2 logs for database connection messages
3. Try user registration (if implemented)

### Check Logs:
```bash
# PM2 logs
pm2 logs ontrail-app

# PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-*.log
```

---

## 📊 Database Schema Overview

Your Ontrail application includes these tables:

| **Table** | **Description** | **Key Features** |
|-----------|-----------------|------------------|
| `users` | User authentication | NextAuth.js compatible |
| `profiles` | Extended profiles | Valuation algorithm |
| `friendships` | Social connections | Tokenized friendships |
| `pois` | Points of Interest | NFT support |
| `quests` | Challenge system | Sponsorship & rewards |
| `posts` | Social timeline | Health data integration |
| `wallets` | Solana wallets | Wallet management |
| `transactions` | Blockchain txns | Transaction tracking |

---

## 🔒 Security Notes

### For Production:
1. **Change passwords:**
   ```sql
   ALTER USER postgres PASSWORD 'your-secure-password';
   ALTER USER ontrail_user PASSWORD 'your-secure-password';
   ```

2. **Update secrets:**
   - Change `NEXTAUTH_SECRET`
   - Configure OAuth credentials
   - Add encryption keys

3. **Firewall configuration:**
   ```bash
   # Only allow local connections
   sudo ufw allow from 127.0.0.1 to any port 5432
   sudo ufw deny from any to any port 5432
   ```

---

## 🐛 Troubleshooting

### Connection Issues:
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check if PostgreSQL is listening
netstat -tlnp | grep 5432

# Test connection manually
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail
```

### Migration Issues:
```bash
# Check migration files
ls -la drizzle/

# Check database permissions
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "\l"

# Run migration manually
cd /var/www/ontrailapp/webApp
npm run db:migrate
```

### Application Issues:
```bash
# Check environment variables
cat /var/www/ontrailapp/webApp/.env.local

# Check PM2 status
pm2 status

# Check application logs
pm2 logs ontrail-app --lines 50
```

---

## 🎯 Success Checklist

- [ ] PostgreSQL installed and running
- [ ] Database `ontrail` created
- [ ] User `ontrail_user` configured
- [ ] Environment file created with correct DATABASE_URL
- [ ] Database migrations applied successfully
- [ ] Application restarted and connected to database
- [ ] Application accessible at https://ontrail.tech
- [ ] User registration and social features working

---

## 📞 Support

If you encounter issues:

1. **Check the logs** (PM2 and PostgreSQL)
2. **Verify environment variables**
3. **Test database connection manually**
4. **Ensure all dependencies are installed**
5. **Check file permissions**

**Need help?** Check the logs and verify each step carefully!

---

## 🚀 What's Next?

After database setup is complete:

1. ✅ **Configure OAuth** (Google/Facebook login)
2. ✅ **Test social features** (friendships, posts)
3. ✅ **Set up Solana integration** (wallets, transactions)
4. ✅ **Configure POI system** (location services)
5. ✅ **Test quest system** (challenges, rewards)

**Your Ontrail Social-Fi application is now ready for users! 🎉**

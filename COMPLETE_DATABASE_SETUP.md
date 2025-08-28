# 🚀 Complete PostgreSQL Setup Guide for Ontrail Social-Fi

## 📋 **Step-by-Step Manual Setup**

Since automated scripts aren't working in the current environment, follow these manual steps:

---

## **Phase 1: Server Access**

### **Step 1: Connect to your server**
```bash
# Open Command Prompt or PowerShell and run:
ssh -i %USERPROFILE%\.ssh\id_rsa_ontrail root@85.208.51.194
```

**Expected Result:** You should see the server prompt: `root@ubuntu:~#`

---

## **Phase 2: Install PostgreSQL**

### **Step 2: Update system and install PostgreSQL**
```bash
# Run these commands on the server:
sudo apt update
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo systemctl status postgresql
```

**Expected Result:** PostgreSQL should be "active (running)"

---

## **Phase 3: Create Database and User**

### **Step 3: Set up PostgreSQL database**
```bash
# Switch to postgres user:
sudo -u postgres psql

# In PostgreSQL shell, run these commands one by one:
ALTER USER postgres PASSWORD 'Tropictiger2025!';
CREATE USER ontrail_user WITH PASSWORD 'Tropictiger2025!';
CREATE DATABASE ontrail OWNER ontrail_user;
GRANT ALL PRIVILEGES ON DATABASE ontrail TO ontrail_user;
\l

# Exit PostgreSQL shell:
\q
```

**Expected Result:** Should show database list with "ontrail" database

---

## **Phase 4: Configure Application**

### **Step 4: Create environment file**
```bash
# Create .env.local file:
cat > /var/www/ontrailapp/webApp/.env.local << 'EOF'
# Database Configuration
DATABASE_URL="postgresql://ontrail_user:Tropictiger2025!@localhost:5432/ontrail"

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
EOF
```

**Expected Result:** File created successfully

---

## **Phase 5: Run Migrations**

### **Step 5: Install dependencies and run migrations**
```bash
# Navigate to application directory:
cd /var/www/ontrailapp/webApp

# Install dependencies:
npm install

# Run database migrations:
npm run db:migrate
```

**Expected Result:** Should show successful migration messages

---

## **Phase 6: Test and Verify**

### **Step 6: Test database connection**
```bash
# Test database connection:
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "SELECT current_database(), current_user;"

# Check tables were created:
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "\dt"
```

**Expected Result:** Should show 13 tables created

### **Step 7: Restart application**
```bash
# Restart the application:
pm2 restart ontrail-app

# Check status:
pm2 status

# View logs:
pm2 logs ontrail-app --lines 10
```

**Expected Result:** Application should be online with no database errors

---

## **Phase 7: Final Verification**

### **Test from your local machine:**
```bash
# Test the website:
curl -I https://ontrail.tech
```

**Expected Result:** HTTP/2 200 OK

---

## 📊 **Database Schema Created**

After successful setup, you'll have these tables:

| **Category** | **Tables** | **Purpose** |
|-------------|------------|-------------|
| **Users** | `users`, `profiles` | Authentication & profiles |
| **Social** | `friendships`, `follows` | Social connections |
| **Content** | `posts`, `comments`, `post_likes` | Social timeline |
| **Location** | `pois`, `poi_visits` | Points of Interest |
| **Challenges** | `quests`, `quest_participants` | Quest system |
| **Blockchain** | `wallets`, `transactions` | Solana integration |

---

## 🐛 **Troubleshooting Guide**

### **If PostgreSQL won't start:**
```bash
# Check status:
sudo systemctl status postgresql

# Check logs:
sudo tail -f /var/log/postgresql/postgresql-*.log

# Restart:
sudo systemctl restart postgresql
```

### **If database connection fails:**
```bash
# Test connection:
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail

# Check user exists:
sudo -u postgres psql -c "SELECT usename FROM pg_user WHERE usename = 'ontrail_user';"

# Check database exists:
sudo -u postgres psql -c "\l" | grep ontrail
```

### **If migrations fail:**
```bash
# Check file permissions:
ls -la /var/www/ontrailapp/webApp/drizzle/

# Check database permissions:
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "\l"

# Run migration manually:
cd /var/www/ontrailapp/webApp
npm run db:migrate
```

### **If application won't start:**
```bash
# Check environment file:
cat /var/www/ontrailapp/webApp/.env.local

# Check PM2 logs:
pm2 logs ontrail-app

# Restart with verbose logging:
pm2 restart ontrail-app
pm2 logs ontrail-app --lines 50
```

---

## 🎯 **Success Checklist**

Run these commands to verify everything is working:

```bash
# 1. Check PostgreSQL is running
sudo systemctl status postgresql

# 2. Test database connection
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "SELECT version();"

# 3. Check tables exist
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "\dt"

# 4. Check application is running
pm2 status

# 5. Check website is accessible
curl -I https://ontrail.tech

# 6. Check for database errors in logs
pm2 logs ontrail-app | grep -i error
```

---

## 🚀 **What Happens Next**

After successful setup:

1. ✅ **User Registration** - Users can create accounts
2. ✅ **Social Features** - Friendships, posts, follows
3. ✅ **Quest System** - Challenges and rewards
4. ✅ **POI Discovery** - Location-based features
5. ✅ **Solana Integration** - Wallet and token features

---

## 📞 **Quick Reference**

### **Database Connection:**
```
Host: localhost
Port: 5432
Database: ontrail
User: ontrail_user
Password: Tropictiger2025!
URL: postgresql://ontrail_user:Tropictiger2025!@localhost:5432/ontrail
```

### **Application Access:**
```
URL: https://ontrail.tech
PM2 Process: ontrail-app
Logs: pm2 logs ontrail-app
```

### **File Locations:**
```
/var/www/ontrailapp/webApp/.env.local    # Environment config
/var/www/ontrailapp/webApp/drizzle/       # Migration files
/var/log/postgresql/                      # PostgreSQL logs
```

---

## 🎉 **Final Result**

Your **Ontrail Social-Fi application** will have:

- ✅ **Complete PostgreSQL database** with 13 tables
- ✅ **Drizzle ORM integration** for type-safe queries
- ✅ **User authentication** with NextAuth.js
- ✅ **Social features** (friendships, posts, follows)
- ✅ **Quest system** with sponsorship
- ✅ **POI discovery** with NFT support
- ✅ **Solana blockchain** integration
- ✅ **Production-ready** configuration

**Follow these steps carefully and your Ontrail application will be fully operational! 🚀✨**

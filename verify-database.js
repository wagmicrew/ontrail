// Quick database verification script
const { Client } = require('pg');

const client = new Client({
  host: 'localhost',
  port: 5432,
  database: 'ontrail_db',
  user: 'ontrail_user',
  password: 'PaX9912!'
});

async function verifyDatabase() {
  try {
    console.log('🔍 Connecting to database...');
    await client.connect();

    console.log('✅ Connected successfully!');

    // Check PostgreSQL version
    const versionResult = await client.query('SELECT version()');
    console.log('📊 PostgreSQL Version:', versionResult.rows[0].version.split(' ')[0] + ' ' + versionResult.rows[0].version.split(' ')[1]);

    // List all tables
    const tablesResult = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      ORDER BY table_name;
    `);

    console.log('📋 Database Tables:');
    tablesResult.rows.forEach(row => {
      console.log(`  - ${row.table_name}`);
    });

    // Test a simple query
    const testResult = await client.query('SELECT COUNT(*) as count FROM users');
    console.log(`👥 Users table has ${testResult.rows[0].count} records`);

    console.log('🎉 Database verification complete!');

  } catch (error) {
    console.error('❌ Database verification failed:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

verifyDatabase();

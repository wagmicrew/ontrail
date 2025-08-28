import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

// Database connection configuration
const connectionString = process.env.DATABASE_URL!;

// Create the connection
const client = postgres(connectionString, {
  max: 1,
  onnotice: () => {}, // Disable notice logs
});

// Create the database instance with schema
export const db = drizzle(client, { schema });

// Export types for use in the application
export type Database = typeof db;

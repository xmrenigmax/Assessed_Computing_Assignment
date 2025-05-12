import { Pool } from 'pg';
import dotenv from 'dotenv';

// Load environment variables from the .env file
dotenv.config();

// Create a connection pool to the PostgreSQL database
const pool = new Pool({
    user: process.env.DB_USER,       // Database username
    host: process.env.DB_HOST,       // Database host (e.g., localhost)
    database: process.env.DB_NAME,   // Database name
    password: process.env.DB_PASSWORD, // Database password
    port: parseInt(process.env.DB_PORT || '5432'), // Database port (default: 5432)
});

// Export the pool so other files can use it
export default pool;


// what this code does:
/**
 * centralises database connection to enable reuse across files, and ensures security through .env file (hidden)
 */
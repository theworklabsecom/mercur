-- Create user if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'medusa') THEN
    CREATE USER medusa WITH PASSWORD 'medusa';
  END IF;
END
$$;

-- Create database if it doesn't exist
SELECT 'CREATE DATABASE medusa'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'medusa')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE medusa TO medusa;

-- Connect to the database and grant schema privileges
\c medusa
GRANT ALL ON SCHEMA public TO medusa;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO medusa;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO medusa;


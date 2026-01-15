#!/bin/bash

echo "Creating PostgreSQL database 'medusa' and user 'medusa'..."
echo ""

# Create user and database
sudo -u postgres psql << 'SQL'
-- Create user if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'medusa') THEN
    CREATE USER medusa WITH PASSWORD 'medusa';
    RAISE NOTICE 'User medusa created';
  ELSE
    ALTER USER medusa WITH PASSWORD 'medusa';
    RAISE NOTICE 'User medusa already exists, password updated';
  END IF;
END
$$;

-- Create database if it doesn't exist
SELECT 'CREATE DATABASE medusa'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'medusa')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE medusa TO medusa;
SQL

# Grant schema privileges
sudo -u postgres psql -d medusa << 'SQL'
GRANT ALL ON SCHEMA public TO medusa;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO medusa;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO medusa;
SQL

echo ""
echo "Database setup complete!"
echo "Verifying..."
sudo -u postgres psql -c "\du" | grep medusa
sudo -u postgres psql -c "\l" | grep medusa
echo ""
echo "You can now run: yarn db:migrate"


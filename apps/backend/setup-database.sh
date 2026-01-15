#!/bin/bash

echo "Setting up PostgreSQL database for Mercur..."
echo "Database: medusa"
echo "User: medusa"
echo "Password: medusa"
echo ""

# Try different methods to connect to PostgreSQL
if command -v psql &> /dev/null; then
    echo "Attempting to create database..."
    
    # Method 1: Try with sudo
    if sudo -n true 2>/dev/null; then
        echo "Using sudo to connect as postgres user..."
        sudo -u postgres psql << EOF
-- Create user if it doesn't exist
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'medusa') THEN
    CREATE USER medusa WITH PASSWORD 'medusa';
  ELSE
    ALTER USER medusa WITH PASSWORD 'medusa';
  END IF;
END
\$\$;

-- Create database if it doesn't exist
SELECT 'CREATE DATABASE medusa'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'medusa')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE medusa TO medusa;
EOF
        
        # Grant schema privileges
        sudo -u postgres psql -d medusa << EOF
GRANT ALL ON SCHEMA public TO medusa;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO medusa;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO medusa;
EOF
        
        echo "Database setup complete!"
        exit 0
    fi
    
    # Method 2: Try connecting as postgres user directly
    echo "Trying to connect as postgres user (you may be prompted for password)..."
    PGPASSWORD=postgres psql -U postgres -h localhost << EOF 2>/dev/null || true
-- Create user if it doesn't exist
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'medusa') THEN
    CREATE USER medusa WITH PASSWORD 'medusa';
  ELSE
    ALTER USER medusa WITH PASSWORD 'medusa';
  END IF;
END
\$\$;

-- Create database if it doesn't exist
SELECT 'CREATE DATABASE medusa'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'medusa')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE medusa TO medusa;
\c medusa
GRANT ALL ON SCHEMA public TO medusa;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO medusa;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO medusa;
EOF
fi

echo ""
echo "If the automatic setup didn't work, please run these commands manually:"
echo ""
echo "  sudo -u postgres psql"
echo ""
echo "Then execute:"
echo "  CREATE USER medusa WITH PASSWORD 'medusa';"
echo "  CREATE DATABASE medusa;"
echo "  GRANT ALL PRIVILEGES ON DATABASE medusa TO medusa;"
echo "  \\c medusa"
echo "  GRANT ALL ON SCHEMA public TO medusa;"
echo "  \\q"


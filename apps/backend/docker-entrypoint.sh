#!/bin/sh
set -e

echo "=========================================="
echo "Mercur Backend - Starting up..."
echo "=========================================="

echo ""
echo "Step 1: Waiting for database to be ready..."
RETRIES=30
until pg_isready -h postgres -U medusa -d medusa || [ $RETRIES -eq 0 ]; do
  echo "  Waiting for database... ($RETRIES retries left)"
  RETRIES=$((RETRIES-1))
  sleep 2
done

if [ $RETRIES -eq 0 ]; then
  echo "✗ ERROR: Database connection failed after 60 seconds!"
  exit 1
fi

echo "✓ Database is ready!"

echo ""
echo "Step 2: Testing database connection..."
export PGPASSWORD=medusa
if psql -h postgres -U medusa -d medusa -c "SELECT 1;" > /dev/null 2>&1; then
  echo "✓ Database connection test passed"
else
  echo "✗ ERROR: Database connection test failed!"
  exit 1
fi

echo ""
echo "Step 3: Ensuring database is initialized..."
# Try to create database structure (safe to run even if exists)
# Temporarily disable exit on error for this step
set +e
npx medusa db:create 2>&1
DB_CREATE_EXIT=$?
set -e
if [ $DB_CREATE_EXIT -eq 0 ]; then
  echo "✓ Database structure created"
else
  echo "  (Database already exists or creation not needed, continuing...)"
fi

echo ""
echo "Step 4: Running database migrations..."
echo "----------------------------------------"
if yarn db:migrate 2>&1; then
  MIGRATION_EXIT=$?
  if [ $MIGRATION_EXIT -eq 0 ]; then
    echo "----------------------------------------"
    echo "✓ Migrations completed successfully"
  else
    echo "----------------------------------------"
    echo "⚠ Migration exited with code $MIGRATION_EXIT"
  fi
else
  MIGRATION_EXIT=$?
  echo "----------------------------------------"
  echo "⚠ Migration command failed with exit code $MIGRATION_EXIT"
fi

echo ""
echo "Step 5: Verifying database tables..."
TABLE_COUNT=$(psql -h postgres -U medusa -d medusa -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';" 2>/dev/null || echo "0")
echo "  Found $TABLE_COUNT tables in database"

if [ "$TABLE_COUNT" -eq "0" ]; then
  echo "✗ ERROR: No tables found! Migrations must have failed."
  echo "  Please check the migration output above for errors."
  exit 1
elif [ "$TABLE_COUNT" -lt "10" ]; then
  echo "⚠ WARNING: Only $TABLE_COUNT tables found. Expected more tables."
  echo "  Migrations may not have completed fully."
else
  echo "✓ Database appears to be properly migrated"
fi

echo ""
echo "=========================================="
echo "Starting Mercur backend server..."
echo "=========================================="
exec yarn start


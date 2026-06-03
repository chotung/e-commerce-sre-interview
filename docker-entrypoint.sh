#!/bin/bash
set -e

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to be ready..."
until mongosh mongodb://$MONGODB_HOST:$MONGODB_PORT/admin --eval "db.adminCommand('ping')" > /dev/null 2>&1; do
  echo "MongoDB is unavailable - sleeping"
  sleep 2
done

echo "MongoDB is up - proceeding"

# Remove any existing server.pid
if [ -f tmp/pids/server.pid ]; then
  rm -f tmp/pids/server.pid
fi

# Create database if it doesn't exist (Mongoid handles this automatically)
echo "Setting up database..."

# Create indexes if needed
bundle exec rake db:create_indexes 2>/dev/null || true

echo "Starting Rails application..."

# Execute the main command
exec "$@"

#!/bin/bash
# Deploy script for tayzhang-app
# Usage: ./deploy.sh

set -e

echo "Starting deployment..."

# Navigate to project directory
cd "$(dirname "$0")/.."

# Pull latest changes
echo "Pulling latest changes..."
git pull origin main

# Update submodules
echo "Updating submodules..."
git submodule update --init --recursive
git submodule foreach git pull origin main

# Build and restart services
echo "Building and restarting services..."
docker compose build
docker compose up -d

# Clean up old images
echo "Cleaning up old images..."
docker image prune -f

# Run database migrations
echo "Running database migrations..."
docker compose exec backend alembic upgrade head || true

# Health check
echo "Checking service health..."
sleep 5
curl -f http://localhost/health || echo "Warning: Health check failed"

echo "Deployment completed!"

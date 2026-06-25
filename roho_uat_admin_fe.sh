#!/bin/bash

set -e

APP_NAME="roho_uat_admin_fe"
REPO_URL="https://solbaacken.git.beanstalkapp.com/roho_admin_fe.git"
BRANCH="uat"

BASE_DIR="/home/ubuntu/deploy"
REPO_DIR="$BASE_DIR/roho_repo"
ENV_FILE="/home/ubuntu/env-files/roho_uat_admin_fe.env"

IMAGE_NAME="$APP_NAME:latest"
CONTAINER_NAME="$APP_NAME-container"

echo "=============================="
echo "🚀 Starting Deployment"
echo "=============================="

# 1. Clean old repo
echo "🔹 Removing old repo..."
rm -rf $REPO_DIR

# 2. Clone fresh repo
echo "🔹 Cloning repository..."
git clone -b $BRANCH $REPO_URL $REPO_DIR

cd $REPO_DIR

# 3. Copy .env from host
echo "🔹 Injecting .env from host server..."
cp $ENV_FILE .env

# 4. Build Docker image
echo "🔹 Building Docker image..."
docker build -t $IMAGE_NAME .

# 5. Stop old container
echo "🔹 Stopping old container..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

# 6. Run new container
echo "🔹 Starting new container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p 80:80 \
  --restart always \
  $IMAGE_NAME

echo "=============================="
echo "✅ Deployment Successful"
echo "=============================="

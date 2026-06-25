#!/bin/bash

set -e

APP_NAME="roho_uat_admin_fe"
REPO_URL="https://solbaacken.git.beanstalkapp.com/roho_admin_fe.git"
BRANCH="uat"

BASE_DIR="/home/ubuntu/deploy"
REPO_DIR="$BASE_DIR/roho_repo"

ENV_FILE="/home/ubuntu/env-files/roho_uat_admin_fe.env"
LOCAL_DOCKERFILE="/home/ubuntu/deploy/Dockerfile"

IMAGE_NAME="$APP_NAME:latest"
CONTAINER_NAME="$APP_NAME-container"

echo "=============================="
echo "🚀 Deployment Started"
echo "=============================="

# 1. Clone repo only if not exists
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "🔹 Repo not found. Cloning first time..."
    git clone -b $BRANCH $REPO_URL $REPO_DIR
fi

cd $REPO_DIR

# 2. Pull latest changes
echo "🔹 Pulling latest code..."
git fetch origin $BRANCH
git reset --hard origin/$BRANCH

# 3. Inject .env from host
echo "🔹 Copying .env..."
cp $ENV_FILE .env

# 4. Copy Dockerfile from local server
echo "🔹 Copying Dockerfile..."
cp $LOCAL_DOCKERFILE ./Dockerfile

# 5. Build Docker image
echo "🔹 Building Docker image..."
docker build -t $IMAGE_NAME .

# 6. Stop old container
echo "🔹 Stopping old container..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

# 7. Run new container
echo "🔹 Running container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p 80:80 \
  --restart always \
  $IMAGE_NAME

echo "=============================="
echo "✅ Deployment Completed"
echo "=============================="

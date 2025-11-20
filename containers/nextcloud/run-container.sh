#!/bin/bash
#
# Nextcloud Container Run Script
# This script runs the Nextcloud container with appropriate Podman configuration
#

set -euo pipefail

# Configuration
CONTAINER_NAME="nextcloud"
IMAGE_NAME="docker.io/linuxserver/nextcloud:32.0.2"
HTTP_PORT="${NEXTCLOUD_HTTP_PORT:-8080}"
HTTPS_PORT="${NEXTCLOUD_HTTPS_PORT:-8443}"
CONFIG_DIR="${NEXTCLOUD_CONFIG_DIR:-/var/lib/nextcloud/config}"
DATA_DIR="${NEXTCLOUD_DATA_DIR:-/var/lib/nextcloud/data}"
TIMEZONE="${TZ:-Etc/UTC}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if podman is available
if ! command -v podman &> /dev/null; then
    error "podman is not installed or not in PATH"
    exit 1
fi

# Create directories if they don't exist
info "Ensuring volume directories exist..."
for dir in "$CONFIG_DIR" "$DATA_DIR"; do
    if [ ! -d "$dir" ]; then
        warn "Creating directory: $dir"
        mkdir -p "$dir"
    fi
done

# Check for existing container
if podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    warn "Container '${CONTAINER_NAME}' already exists"
    read -p "Do you want to remove and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Stopping and removing existing container..."
        podman stop "$CONTAINER_NAME" 2>/dev/null || true
        podman rm "$CONTAINER_NAME" 2>/dev/null || true
    else
        error "Exiting. Please remove the container manually or choose a different name."
        exit 1
    fi
fi

# Pull the image
info "Pulling image: $IMAGE_NAME"
podman pull "$IMAGE_NAME"

# Run the container
info "Starting Nextcloud container..."
podman run -d \
    --name "$CONTAINER_NAME" \
    -e PUID="$(id -u)" \
    -e PGID="$(id -g)" \
    -e TZ="$TIMEZONE" \
    -p "${HTTP_PORT}:80" \
    -p "${HTTPS_PORT}:443" \
    -v "${CONFIG_DIR}:/config:Z" \
    -v "${DATA_DIR}:/data:Z" \
    --restart=always \
    "$IMAGE_NAME"

# Wait a moment for the container to start
sleep 2

# Check if container is running
if podman ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    info "Container started successfully!"
    info ""
    info "Container details:"
    info "  Name: $CONTAINER_NAME"
    info "  HTTP Port: $HTTP_PORT"
    info "  HTTPS Port: $HTTPS_PORT"
    info "  Config Dir: $CONFIG_DIR"
    info "  Data Dir: $DATA_DIR"
    info ""
    info "Access Nextcloud at:"
    info "  HTTP:  http://localhost:${HTTP_PORT}"
    info "  HTTPS: https://localhost:${HTTPS_PORT}"
    info ""
    info "View logs with: podman logs -f $CONTAINER_NAME"
    info "Stop container with: podman stop $CONTAINER_NAME"
else
    error "Container failed to start!"
    info "Check logs with: podman logs $CONTAINER_NAME"
    exit 1
fi

#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Configuration
REGISTRY="registry.0.os76.xyz"
REGISTRY_USER="xeno"
IMAGE_NAME="netdrill"
IMAGE_TAG="v0.0.4"
FULL_IMAGE_NAME="${REGISTRY}/${REGISTRY_USER}/${IMAGE_NAME}"
LABEL_SOURCE="https://git.priv.os76.xyz/xeno/netdrill"
LABEL_CREATED="$(date -Iseconds)"
LABEL_REVISION="$(git rev-parse HEAD)"

# Builder Setup
BUILDER_NAME="netdrill-builder"

show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help message"
  echo "  --push        Build multi-arch (amd64, arm64) and push to ${REGISTRY}"
  echo ""
  echo "Default (no options): Build for local architecture and load into Docker daemon."
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
  exit 0
fi

echo "Checking for buildx builder: ${BUILDER_NAME}..."

if ! docker buildx inspect "${BUILDER_NAME}" &>/dev/null; then
  echo "Creating new buildx builder..."
  docker buildx create --name "${BUILDER_NAME}" --use
else
  echo "Using existing buildx builder..."
  docker buildx use "${BUILDER_NAME}"
fi

# Ensure the builder is started
docker buildx inspect --bootstrap

# Default Action
ACTION="--load"
PLATFORMS="linux/$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')"

if [ "$1" == "--push" ]; then
  ACTION="--push"
  PLATFORMS="linux/amd64,linux/arm64"
  echo "Action set to PUSH to registry: ${REGISTRY}"

  # Authenticate
  echo "Authenticating to ${REGISTRY} as ${REGISTRY_USER}..."
  docker login "${REGISTRY}" -u "${REGISTRY_USER}"
fi

echo "Building image for platforms: ${PLATFORMS}"

docker buildx build \
  --platform "${PLATFORMS}" \
  --build-arg LABEL_SOURCE="${LABEL_SOURCE}" \
  --build-arg LABEL_CREATED="${LABEL_CREATED}" \
  --build-arg LABEL_REVISION="${LABEL_REVISION}" \
  -t "${FULL_IMAGE_NAME}:${IMAGE_TAG}" \
  -t "${FULL_IMAGE_NAME}:latest" \
  "${ACTION}" .

echo "Build complete!"
echo "You can now launch the newly uploaded image with one of the following commands:"
echo "docker run --hostname netdrill-latest --rm -it registry.0.os76.xyz/xeno/netdrill:latest"
echo "docker run --hostname netdrill --rm -it registry.0.os76.xyz/xeno/netdrill:${IMAGE_TAG}"

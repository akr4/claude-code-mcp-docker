set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# List tasks
default:
  @just --list

DOCKER_IMAGE_NAME := "my-claude-mcp:latest"

# Build Docker image
build:
  @echo "Building Docker image..."
  docker build -t {{DOCKER_IMAGE_NAME}} .

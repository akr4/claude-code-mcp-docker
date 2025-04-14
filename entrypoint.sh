#!/bin/bash
set -e

# Check if we have the necessary capabilities
if [ ! -e "/proc/sys/net/ipv4/ip_forward" ]; then
  echo "ERROR: NET_ADMIN capability not available. Container must be run with '--cap-add=NET_ADMIN'" >&2
  exit 1
fi

# Initialize firewall as root
echo "Initializing security firewall..." >&2
/usr/local/bin/init-firewall.sh

# Configure git email if provided
if [ ! -z "${GIT_USER_EMAIL}" ]; then
  echo "Setting Git email to ${GIT_USER_EMAIL}" >&2
  # Set for root user
  git config --global user.email "${GIT_USER_EMAIL}"
  # Set for non-root user
  su -c "git config --global user.email \"${GIT_USER_EMAIL}\"" $USERNAME
fi

# Switch to non-root user and start the MCP server
echo "Switching to user $USERNAME for running Claude Code MCP server" >&2
exec su -c "/root/.local/bin/mise exec -- claude mcp serve" $USERNAME

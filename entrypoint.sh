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

# Make sure workspace directory has correct permissions
echo "Ensuring workspace directory permissions..." >&2
chown -R $USERNAME:$USERNAME /workspace

# Switch to non-root user and start the MCP server
echo "Starting Claude Code MCP server as user $USERNAME..." >&2
exec su -c "/root/.local/bin/mise exec -- claude mcp serve" $USERNAME

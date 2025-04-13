# Dockerized Claude Code MCP Server

A simple Docker container for running Claude Code MCP server with enhanced security features.

## Development Environment

This Docker container provides a pre-configured development environment with:

- **Base OS**: Ubuntu
- **Build Tools**: git, curl, wget, etc.
- **Security**: Network firewall to prevent unauthorized outbound connections

You can customize the Dockerfile to add additional development tools or languages specific to your projects.

## Setup Instructions

### 1. Build Docker Image

```bash
docker build -t my-claude-mcp:latest .
```

Or if you have [just](https://github.com/casey/just) installed:
```bash
just build
```

### 2. MCP Client Configuration

#### (Example) Claude Desktop Configuration

Configure Claude Desktop settings file (`~/Library/Application\ Support/Claude/claude_desktop_config.json` on macOS for example) as follows:

```json
{
  "mcpServers": {
    "claude-code": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "--cap-add=NET_ADMIN",
        "--cap-add=NET_RAW",
        "-v", "/Users/username/.claude:/home/node/.claude",
        "-v", "/Users/username/project-1:/workspaces/project-1",
        "-v", "/Users/username/project-2:/workspaces/project-2",
        "my-claude-mcp:latest"
      ]
    }
  }
}
```

This configuration:
- Mounts your Claude settings directory (`~/.claude`)
- Mounts your project directories for access within the container
- Gives you the flexibility to add as many project directories as needed

## Customization

Feel free to modify the Dockerfile to add more development tools based on your needs. For example:

- Additional programming languages (Go, Python, etc.)
- Database clients
- Cloud CLIs (AWS, GCP, Azure)
- Container tools (Docker, Kubernetes tools)

After modifying the Dockerfile, rebuild the image with:
```bash
docker build -t my-claude-mcp:latest .
```

Or with just:
```bash
just build
```

Then restart your MCP client connection.

## Security Features

This container includes a network firewall that restricts outbound connections to only approved domains:

- GitHub domains (api.github.com, github.com, etc.)
- NPM registry (registry.npmjs.org)
- Anthropic APIs (api.anthropic.com, statsig.anthropic.com)
- Rust-related domains (crates.io, static.rust-lang.org, etc.)
- Other required services (sentry.io, etc.)

The firewall is automatically enabled when the container is started with the necessary capabilities (`--cap-add=NET_ADMIN` and `--cap-add=NET_RAW`). If these capabilities are not provided, the container will still run but without the network security restrictions.

This security feature helps prevent potential data exfiltration attempts through the MCP server.

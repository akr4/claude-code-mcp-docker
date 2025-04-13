FROM ubuntu:24.04

ARG USERNAME=node

RUN apt-get update && apt-get install -y \
    curl wget git build-essential \
    iptables ipset iproute2 dnsutils aggregate jq sudo

WORKDIR /workspace

#---------------------------
# Basic tools
#---------------------------
RUN curl https://mise.run | sh
ENV PATH="/root/.local/bin:$PATH"

# node & Claude Code
RUN mise install node && mise use node
RUN mise exec -- npm install -g @anthropic-ai/claude-code


#---------------------------
# Other tools
#---------------------------
# uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"


#----------------------------
# Run Claude Code
#----------------------------
# Create entrypoint script to run firewall setup and then start the MCP server
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Initialize firewall if NET_ADMIN capability is available\n\
if [ -e "/proc/sys/net/ipv4/ip_forward" ]; then\n\
  echo "Initializing security firewall..."\n\
  /usr/local/bin/init-firewall.sh\n\
else\n\
  echo "NET_ADMIN capability not available, skipping firewall setup"\n\
fi\n\
\n\
# Start the MCP server\n\
exec mise exec -- claude mcp serve\n\
' > /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]

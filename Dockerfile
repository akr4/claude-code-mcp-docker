FROM ubuntu:24.04

ARG USERNAME=claude

# Install security tools and basic dependencies
RUN apt-get update && apt-get install -y \
    curl wget git build-essential \
    iptables ipset iproute2 dnsutils aggregate jq sudo \
    # For creating non-root user
    ca-certificates gnupg2

# Create non-root user with system-assigned UID/GID
RUN useradd -m $USERNAME

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

#---------------------------
# Firewall
#---------------------------
COPY init-firewall.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-firewall.sh

# Set up workspace directory
RUN mkdir -p /workspace && chown -R $USERNAME:$USERNAME /workspace

# Switch to non-root user
USER $USERNAME
WORKDIR /workspace

# Git configuration will be handled in entrypoint.sh

# Switch back to root for entrypoint
USER root


#---------------------------
# Entrypoint
#---------------------------
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

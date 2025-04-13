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

# Add mise to PATH for non-root user
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /home/$USERNAME/.bashrc && \
    echo 'eval "$(mise activate bash)"' >> /home/$USERNAME/.bashrc

# Make sure user can access mise
RUN mkdir -p /home/$USERNAME/.local/bin && \
    cp /root/.local/bin/mise /home/$USERNAME/.local/bin/ && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.local

# Copy security scripts
COPY init-firewall.sh /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/entrypoint.sh

# Create workspace directory with proper permissions
RUN mkdir -p /workspace && chown -R $USERNAME:$USERNAME /workspace

# Switch to root to start with entrypoint.sh
USER root

# This CMD will be overridden by the ENTRYPOINT
CMD ["mise", "exec", "--", "claude", "mcp", "serve"]

# Use entrypoint.sh as the entry point to handle permissions correctly
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

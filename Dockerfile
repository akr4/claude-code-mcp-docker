FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    curl wget git build-essential

ENV PATH="/root/.local/bin:$PATH"


#---------------------------
# Basic tools
#---------------------------
RUN curl https://mise.run | sh

# node
# required for Claude Code
RUN mise install node && mise use node


#---------------------------
# Other tools
#---------------------------
# uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"


#----------------------------------------------
# Claude Code
#----------------------------------------------
RUN mise exec -- npm install -g @anthropic-ai/claude-code
CMD ["mise", "exec", "--", "claude", "mcp", "serve"]

FROM ghcr.io/ansible/community-ansible-dev-tools:v26.6.1

ENV TZ="UTC"

# Install Node.js, sudo, and CLI tools (Fedora uses dnf)
RUN dnf install -y nodejs npm sudo curl jq gh uv tmux unzip && dnf clean all

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Multi-provider model router (replaces Abbenay, which was Ansible
# Lightspeed's local backend — Lightspeed is retired from this devcontainer).
# claude-code-router (ccr) sits in front of Claude Code and routes each
# request to whichever of your Anthropic/OpenAI/Gemini keys fits the task —
# see ccr-config.json for the actual routing weights. Doc lookup is still
# covered by the ansible-know/ansible MCP servers (mcp-servers.json); lint
# feedback by the ansible-lint Claude Code hook (init-claude-hooks.sh).
# See: https://github.com/musistudio/claude-code-router
RUN npm install -g @musistudio/claude-code-router

# Config uses ccr's native $VAR/${VAR} interpolation — no keys baked into
# the image, they're resolved from ANTHROPIC_API_KEY/OPENAI_API_KEY/
# GEMINI_API_KEY at container start (see devcontainer.json containerEnv).
RUN mkdir -p /root/.claude-code-router
COPY ccr-config.json /root/.claude-code-router/config.json

ARG DEVCONTAINER_VERSION=1.5.0
RUN echo "$DEVCONTAINER_VERSION" > /etc/devcontainer-version
ENV DEVCONTAINER_TEMPLATE_VERSION=$DEVCONTAINER_VERSION
ENV DEVCONTAINER=true

# Symlink ~/.ansible to /workspace/.ansible so all Ansible tools
# (galaxy, lint, navigator) converge under the workspace mount
RUN rm -rf /root/.ansible && ln -s /workspace/.ansible /root/.ansible

# Copy and set up startup scripts
COPY init-registry-auth.sh init-ccr.sh init-claude-md.sh init-mcp-config.sh \
     init-claude-hooks.sh ansible-lint-hook.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-registry-auth.sh /usr/local/bin/init-ccr.sh \
    /usr/local/bin/init-claude-md.sh /usr/local/bin/init-mcp-config.sh \
    /usr/local/bin/init-claude-hooks.sh /usr/local/bin/ansible-lint-hook.sh

WORKDIR /workspace

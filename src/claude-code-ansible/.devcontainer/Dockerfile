FROM ghcr.io/ansible/community-ansible-dev-tools:v26.6.1

ENV TZ="UTC"

# Install Node.js, sudo, and CLI tools (Fedora uses dnf)
RUN dnf install -y nodejs npm sudo curl jq gh uv tmux unzip && dnf clean all

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Download Abbenay AI provider gateway (VS Code extension + bundled daemon).
# Abbenay was Ansible Lightspeed's local backend here; Lightspeed is retired
# from this devcontainer in favor of Claude Code + the ansible-know/ansible
# MCP servers (see mcp-servers.json) plus the ansible-lint Claude Code hook
# (see init-claude-hooks.sh). Default is "none" — set --build-arg
# ABBENAY_VERSION=vX.Y.Z to bring it back if some other OpenAI-API-speaking
# tool ever needs it. See: https://github.com/redhat-developer/abbenay
ARG ABBENAY_VERSION=none
RUN if [ "$ABBENAY_VERSION" != "none" ]; then \
      arch=$(uname -m | sed 's/x86_64/x64/' | sed 's/aarch64/arm64/') && \
      version_num=$(echo "$ABBENAY_VERSION" | sed 's/^v//') && \
      curl -fsSL -L "https://github.com/redhat-developer/abbenay/releases/download/${ABBENAY_VERSION}/abbenay-provider-linux-${arch}-${version_num}.vsix" \
        -o /opt/abbenay-provider.vsix; \
    fi

# Default Abbenay config (env var based, no keychain in containers)
RUN mkdir -p /root/.config/abbenay
COPY abbenay-config.yaml /root/.config/abbenay/config.yaml

ARG DEVCONTAINER_VERSION=1.5.0
RUN echo "$DEVCONTAINER_VERSION" > /etc/devcontainer-version
ENV DEVCONTAINER_TEMPLATE_VERSION=$DEVCONTAINER_VERSION
ENV DEVCONTAINER=true

# Symlink ~/.ansible to /workspace/.ansible so all Ansible tools
# (galaxy, lint, navigator) converge under the workspace mount
RUN rm -rf /root/.ansible && ln -s /workspace/.ansible /root/.ansible

# Copy and set up startup scripts
COPY init-registry-auth.sh init-abbenay.sh init-claude-md.sh init-mcp-config.sh \
     init-claude-hooks.sh ansible-lint-hook.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-registry-auth.sh /usr/local/bin/init-abbenay.sh \
    /usr/local/bin/init-claude-md.sh /usr/local/bin/init-mcp-config.sh \
    /usr/local/bin/init-claude-hooks.sh /usr/local/bin/ansible-lint-hook.sh

WORKDIR /workspace

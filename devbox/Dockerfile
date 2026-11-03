# Multi-architecture Developer Environment Container
FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH="/usr/local/bin:/home/devbox/.local/bin:${PATH}" \
    EDITOR="micro" \
    VISUAL="micro"

# Step 1: Base dependencies & core build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    git \
    sudo \
    python3 \
    python3-pip \
    python3-venv \
    pipx \
    fzf \
    ripgrep \
    fd-find \
    zoxide \
    bat \
    jq \
    btop \
    micro \
    supervisor \
    openssh-client \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Step 2: Configure non-root developer user (UID/GID 1000) with sudo access
RUN (usermod -l devbox -d /home/devbox -m ubuntu 2>/dev/null && groupmod -n devbox ubuntu 2>/dev/null) || \
    (groupadd -g 1000 devbox 2>/dev/null && useradd -u 1000 -g devbox -m -s /bin/bash devbox) && \
    chsh -s /bin/bash devbox && \
    usermod -aG sudo devbox && \
    echo "devbox ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/devbox && \
    chmod 0440 /etc/sudoers.d/devbox

# Step 3: Symlinks for standard tools
RUN ln -sf /usr/bin/batcat /usr/local/bin/bat && \
    ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Step 4: Modern CLI Stack (eza, gh, zellij, uv, lazygit, lazydocker, starship)
RUN mkdir -p /etc/apt/keyrings && \
    wget -qO - https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg && \
    chmod 644 /etc/apt/keyrings/gierens.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" > /etc/apt/sources.list.d/gierens.list && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg 2>/dev/null && \
    chmod 644 /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y --no-install-recommends eza gh && \
    rm -rf /var/lib/apt/lists/*

RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64) Z_ARCH="x86_64" ;; \
      aarch64|arm64) Z_ARCH="aarch64" ;; \
      *) Z_ARCH="x86_64" ;; \
    esac && \
    curl -fsSL "https://github.com/zellij-org/zellij/releases/latest/download/zellij-${Z_ARCH}-unknown-linux-musl.tar.gz" -o /tmp/zellij.tar.gz && \
    tar -xzf /tmp/zellij.tar.gz -C /usr/local/bin zellij && \
    rm -f /tmp/zellij.tar.gz && \
    curl -fsSL https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh && \
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y

RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64) LG_ARCH="x86_64" ;; \
      aarch64|arm64) LG_ARCH="arm64" ;; \
      *) LG_ARCH="x86_64" ;; \
    esac && \
    LG_VER=$(curl -sI https://github.com/jesseduffield/lazygit/releases/latest 2>/dev/null | grep -i "^location:" | sed -E 's/.*tag\/v?//' | tr -d '\r\n') && \
    LG_VER=${LG_VER:-0.44.1} && \
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VER}/lazygit_${LG_VER}_Linux_${LG_ARCH}.tar.gz" -o /tmp/lazygit.tar.gz && \
    tar -xzf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit && \
    rm -f /tmp/lazygit.tar.gz && \
    curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | env DIR="/usr/local/bin" bash

# Step 5: Docker CLI and Docker Compose Plugin (for Docker socket mounting)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/* && \
    (getent group docker >/dev/null 2>&1 || groupadd -g 999 docker) && \
    usermod -aG docker devbox 2>/dev/null || true

# Step 6: Node.js 20 LTS & AI Agents
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g @anthropic-ai/claude-code @google/gemini-cli && \
    env PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install aider-chat && \
    (curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- --dir /usr/local/bin || true) && \
    (curl -fsSL https://opencode.ai/install | bash || true) && \
    if [ -f /root/.opencode/bin/opencode ]; then \
      mv /root/.opencode/bin/opencode /usr/local/bin/opencode; \
    fi

# Step 7: Web Terminal (ttyd)
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64) TTYD_ARCH="x86_64" ;; \
      aarch64|arm64) TTYD_ARCH="aarch64" ;; \
      *) TTYD_ARCH="x86_64" ;; \
    esac && \
    curl -fsSL -o /usr/local/bin/ttyd "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${TTYD_ARCH}" && \
    chmod +x /usr/local/bin/ttyd

# Step 8: Browser IDE (code-server)
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Configure user profile, extensions, and iPad/PWA settings for devbox user
RUN su - devbox -c 'mkdir -p /home/devbox/.local/share/code-server/User /home/devbox/.config/code-server /home/devbox/workspace && \
    for ext in ms-python.python esbenp.prettier-vscode eamodio.gitlens usernamehw.errorlens redhat.vscode-yaml; do \
      code-server --install-extension "$ext" 2>/dev/null || true; \
    done'

# Write iPad / Tablet settings
RUN cat << 'EOF' > /home/devbox/.local/share/code-server/User/settings.json
{
  "editor.minimap.enabled": false,
  "editor.wordWrap": "on",
  "editor.fontSize": 14,
  "editor.lineHeight": 22,
  "editor.smoothScrolling": true,
  "editor.mouseWheelZoom": true,
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.lineHeight": 1.2,
  "terminal.integrated.scrollback": 5000,
  "workbench.startupEditor": "none",
  "workbench.tips.enabled": false,
  "workbench.editor.showTabs": "multiple",
  "workbench.editor.tabSizing": "shrink",
  "window.titleBarStyle": "custom",
  "window.autoDetectColorScheme": true,
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000
}
EOF
RUN chown -R devbox:devbox /home/devbox/.local

# Write shell profile
RUN cat << 'EOF' >> /home/devbox/.bashrc

# User environment & aliases
export PATH="/usr/local/bin:~/.local/bin:$PATH"
export EDITOR="micro"
export VISUAL="micro"

alias ls='eza --icons --group-directories-first'
alias ll='eza -alF --icons --group-directories-first'
alias cat='bat -pp'
alias grep='rg'
alias find='fd'

# Initialize Zoxide (Smart cd)
eval "$(zoxide init bash)"
alias cd='z'

# Initialize Starship Prompt
eval "$(starship init bash)"
EOF
RUN chown devbox:devbox /home/devbox/.bashrc

# Supervisor and Entrypoint orchestration
COPY supervisord.conf /etc/supervisor/conf.d/devbox.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chown devbox:devbox /etc/supervisor/conf.d/devbox.conf

# Switch to unprivileged devbox user
USER devbox
WORKDIR /home/devbox/workspace

EXPOSE 8080 7681

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -fsSL http://127.0.0.1:8080/healthz || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/devbox.conf"]

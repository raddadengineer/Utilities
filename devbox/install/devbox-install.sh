#!/usr/bin/env bash
# Copyright (c) 2021-2026 tteck
# Author: raddadengineer
# License: MIT

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Core Dependencies"
$STD apt-get install -y \
  curl \
  wget \
  git \
  sudo \
  build-essential \
  python3 \
  python3-pip \
  python3-venv \
  pipx \
  openssh-server \
  ca-certificates \
  gnupg \
  lsb-release \
  fzf \
  ripgrep \
  fd-find \
  zoxide \
  bat \
  jq
msg_ok "Installed Core Dependencies"

msg_info "Configuring Auto-Login"
# 1. Override for standard LXC TTY
$STD mkdir -p /etc/systemd/system/container-getty@1.service.d
cat <<EOF >/etc/systemd/system/container-getty@1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear --keep-baud tty%I 115200,38400,9600 \$TERM
EOF

# 2. Override for Proxmox Web GUI Console (xterm.js)
$STD mkdir -p /etc/systemd/system/console-getty.service.d
cat <<EOF >/etc/systemd/system/console-getty.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear --keep-baud console 115200,38400,9600 \$TERM
EOF

$STD systemctl daemon-reload
$STD systemctl restart container-getty@1.service console-getty.service || true
msg_ok "Configured Auto-Login"

msg_info "Configuring Modern CLI Stack"
$STD mkdir -p /usr/local/bin /etc/apt/keyrings
$STD chmod 755 /etc/apt/keyrings

# Symlink bat and fd system-wide
$STD ln -sf /usr/bin/batcat /usr/local/bin/bat
$STD ln -sf /usr/bin/fdfind /usr/local/bin/fd

# eza modern ls replacement
$STD wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg
$STD chmod 644 /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list >/dev/null
$STD apt-get update
$STD apt-get install -y eza

# zellij terminal multiplexer
$STD curl -L https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /usr/local/bin zellij

# uv fast Python package manager (system-wide)
$STD env UV_INSTALL_DIR="/usr/local/bin" sh <(curl -LsSf https://astral.sh/uv/install.sh)
msg_ok "Configured Modern CLI Stack"

msg_info "Installing Docker & Container Tools"
$STD sh <(curl -fsSL https://get.docker.com)

# lazydocker (system-wide)
$STD env DIR="/usr/local/bin" bash <(curl -s https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh)

# lazygit (avoiding GitHub API rate limits via HTTP redirect location header)
LAZYGIT_VERSION=$(curl -sI https://github.com/jesseduffield/lazygit/releases/latest | grep -i "^location:" | sed -E 's/.*tag\/v?//' | tr -d '\r\n')
if [[ -z "$LAZYGIT_VERSION" ]]; then
  LAZYGIT_VERSION="0.44.1"
fi
$STD curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
$STD tar -xzf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit
rm -f /tmp/lazygit.tar.gz
msg_ok "Installed Docker & Container Tools"

msg_info "Installing Node.js"
$STD bash <(curl -fsSL https://deb.nodesource.com/setup_20.x)
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Installing AI Agents"
$STD npm install -g @anthropic-ai/claude-code
$STD npm install -g @google/gemini-cli
$STD pipx ensurepath
$STD env PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install aider-chat
$STD curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- --dir /usr/local/bin
$STD bash <(curl -fsSL https://opencode.ai/install)
$STD ln -sf /root/.opencode/bin/opencode /usr/local/bin/opencode
msg_ok "Installed AI Agents"

msg_info "Installing Browser IDE (code-server)"
CODE_SERVER_PW="${PASSWORD:-devbox}"
mkdir -p /root/.config/code-server
cat <<EOF >/root/.config/code-server/config.yaml
bind-addr: 0.0.0.0:8080
auth: password
password: ${CODE_SERVER_PW}
cert: false
EOF
$STD sh <(curl -fsSL https://code-server.dev/install.sh)
$STD systemctl enable --now code-server@root
msg_ok "Installed Browser IDE"

msg_info "Installing Resource Monitor (btop) & Prompt (Starship)"
$STD apt-get install -y btop
$STD curl -sS https://starship.rs/install.sh | sh -s -- -y
msg_ok "Installed btop and Starship"

msg_info "Configuring Shell Profile & Aliases"
cat << 'EOF' >> /root/.bashrc

# Ensure system-wide and user local binaries are in PATH
export PATH="/usr/local/bin:~/.local/bin:$PATH"

# Modern CLI Aliases
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
msg_ok "Configured Shell Profile"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"

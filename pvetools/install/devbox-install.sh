#!/usr/bin/env bash
# Copyright (c) 2021-2024 tteck
# Author: raddadengineer
# License: MIT

msg_info "Updating Base System"
$STD apt-get update
$STD apt-get upgrade -y
msg_ok "Updated Base System"

msg_info "Installing Core Dependencies"
$STD apt-get install -y curl wget git sudo build-essential python3 python3-pip python3-venv pipx openssh-server ca-certificates gnupg lsb-release fzf ripgrep fd-find zoxide bat
msg_ok "Installed Core Dependencies"

msg_info "Configuring Auto-Login"
# This systemd override tells the container's console to bypass the login prompt
$STD mkdir -p /etc/systemd/system/container-getty@1.service.d
echo "[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear --keep-baud tty%I 115200,38400,9600 \$TERM" >/etc/systemd/system/container-getty@1.service.d/override.conf
$STD systemctl daemon-reload
$STD systemctl restart container-getty@1.service
msg_ok "Configured Auto-Login"

msg_info "Configuring Modern CLI Stack"
$STD mkdir -p ~/.local/bin
$STD ln -s /usr/bin/batcat ~/.local/bin/bat || true
$STD ln -s /usr/bin/fdfind ~/.local/bin/fd || true
$STD wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list >/dev/null
$STD apt-get update
$STD apt-get install -y eza
$STD curl -L https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /usr/local/bin zellij
$STD sh <(curl -LsSf https://astral.sh/uv/install.sh)
msg_ok "Configured Modern CLI Stack"

msg_info "Installing Docker & Container Tools"
$STD sh <(curl -fsSL https://get.docker.com)
$STD bash <(curl -s https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh)
$STD install -m 755 ~/.local/bin/lazydocker /usr/local/bin/
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
$STD curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
$STD tar xf lazygit.tar.gz lazygit
$STD install -m 755 lazygit /usr/local/bin
$STD rm lazygit.tar.gz lazygit
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
$STD bash <(curl -fsSL https://antigravity.google/install.sh)
$STD bash <(curl -fsSL https://opencode.ai/install)
msg_ok "Installed AI Agents"

msg_info "Installing Browser IDE (code-server)"
$STD sh <(curl -fsSL https://code-server.dev/install.sh)
$STD systemctl enable --now code-server@root
sleep 2
sed -i 's/bind-addr: 127.0.0.1:8080/bind-addr: 0.0.0.0:8080/g' ~/.config/code-server/config.yaml
$STD systemctl restart code-server@root
msg_ok "Installed Browser IDE"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"

#!/usr/bin/env bash

# Export community-scripts repository URL for custom installer resolution
export COMMUNITY_SCRIPTS_URL="${COMMUNITY_SCRIPTS_URL:-https://raw.githubusercontent.com/raddadengineer/Utilities/main/devbox}"

# Fallback interceptor for legacy single-root engines
curl() {
  local args=()
  for arg in "$@"; do
    if [[ "$arg" == *"community-scripts/ProxmoxVE/main/install/"* ]]; then
      arg="${COMMUNITY_SCRIPTS_URL}/install/devbox-install.sh"
    fi
    args+=("$arg")
  done
  command curl "${args[@]}"
}

_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func") 2>/dev/null || source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 tteck
# Author: raddadengineer
# License: MIT

function header_info {
clear
cat <<"EOF"
    ____             __               
   / __ \___ _   __/ /_  ____  _  __
  / / / / _ \ | / / __ \/ __ \| |/_/
 / /_/ /  __/ |/ / /_/ / /_/ />  <  
/_____/\___/|___/_.___/\____/_/|_|  
                                    
EOF
}
header_info
echo -e "Loading..."
APP="Devbox"
var_tags="${var_tags:-dev;docker;ai}"
var_disk="40"
var_cpu="4"
var_ram="4096"
var_os="ubuntu"
var_version="24.04"
var_unprivileged="1"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1" # 1 = Unprivileged
  PW=""
  CT_ID=$NEXTID
  HN=$APP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="yes"
  VERB="no"
  TAGS="$var_tags"
  FEATURES="nesting=1,keyctl=1" 
  echo_default
}

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if ! command -v code-server &>/dev/null && ! command -v ttyd &>/dev/null; then
    msg_error "No ${APP} Installation Found!"
    exit 1
  fi

  msg_info "Updating Base System & APT Packages"
  apt-get update &>/dev/null
  apt-get -y upgrade &>/dev/null
  msg_ok "Updated Base System & APT Packages"

  if command -v code-server &>/dev/null; then
    msg_info "Updating Browser IDE (code-server)"
    curl -fsSL -o /tmp/code-server-install.sh https://code-server.dev/install.sh &>/dev/null
    sh /tmp/code-server-install.sh &>/dev/null || true
    rm -f /tmp/code-server-install.sh
    systemctl restart code-server@root 2>/dev/null || true
    msg_ok "Updated Browser IDE (code-server)"
  fi

  if command -v ttyd &>/dev/null; then
    msg_info "Updating Web Terminal (ttyd)"
    TTYD_ARCH="x86_64"
    case "$(uname -m)" in
      x86_64) TTYD_ARCH="x86_64" ;;
      aarch64|arm64) TTYD_ARCH="aarch64" ;;
    esac
    curl -fsSL -o /usr/local/bin/ttyd "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${TTYD_ARCH}" &>/dev/null
    chmod +x /usr/local/bin/ttyd
    if grep -q -- "-c root:" /etc/systemd/system/ttyd.service 2>/dev/null; then
      OLD_PW=$(grep '^password:' /root/.config/code-server/config.yaml 2>/dev/null | awk '{print $2}')
      echo "root:${OLD_PW:-devbox}" | chpasswd 2>/dev/null || true
      sed -i '/-c root:/d' /etc/systemd/system/ttyd.service
      sed -i 's/-W \\/-W \\\n  -P 5 \\/' /etc/systemd/system/ttyd.service
      sed -i 's/^  bash$/  login/' /etc/systemd/system/ttyd.service
      systemctl daemon-reload 2>/dev/null || true
    fi
    systemctl restart ttyd 2>/dev/null || true
    msg_ok "Updated Web Terminal (ttyd)"
  fi

  if command -v npm &>/dev/null; then
    msg_info "Updating Global NPM Packages (Claude Code, Gemini CLI)"
    npm update -g &>/dev/null || true
    msg_ok "Updated Global NPM Packages"
  fi

  if command -v uv &>/dev/null; then
    msg_info "Updating Python Package Manager (uv)"
    uv self update &>/dev/null || true
    msg_ok "Updated uv"
  fi

  if command -v pipx &>/dev/null; then
    msg_info "Updating pipx Packages (Aider)"
    env PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx upgrade-all &>/dev/null || true
    msg_ok "Updated pipx Packages"
  fi

  if command -v agy &>/dev/null; then
    msg_info "Updating Antigravity CLI (agy)"
    curl -fsSL -o /tmp/agy-install.sh https://antigravity.google/cli/install.sh &>/dev/null && \
      bash /tmp/agy-install.sh --dir /usr/local/bin &>/dev/null && \
      rm -f /tmp/agy-install.sh || true
    msg_ok "Updated Antigravity CLI"
  fi

  if command -v opencode &>/dev/null; then
    msg_info "Updating OpenCode"
    opencode upgrade &>/dev/null || {
      curl -fsSL -o /tmp/opencode-install.sh https://opencode.ai/install &>/dev/null && \
        bash /tmp/opencode-install.sh &>/dev/null && \
        rm -f /tmp/opencode-install.sh && \
        ln -sf /root/.opencode/bin/opencode /usr/local/bin/opencode || true
    }
    msg_ok "Updated OpenCode"
  fi

  if command -v lazydocker &>/dev/null; then
    msg_info "Updating lazydocker"
    curl -fsSL -o /tmp/lazydocker-install.sh https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh &>/dev/null && \
      env DIR="/usr/local/bin" bash /tmp/lazydocker-install.sh &>/dev/null && \
      rm -f /tmp/lazydocker-install.sh || true
    msg_ok "Updated lazydocker"
  fi

  if command -v lazygit &>/dev/null; then
    msg_info "Updating lazygit"
    LAZYGIT_VERSION=$(curl -sI https://github.com/jesseduffield/lazygit/releases/latest 2>/dev/null | grep -i "^location:" | sed -E 's/.*tag\/v?//' | tr -d '\r\n')
    if [[ -z "$LAZYGIT_VERSION" ]]; then
      LAZYGIT_VERSION="0.44.1"
    fi
    curl -fsSL -o /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" &>/dev/null && \
      tar -xzf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit &>/dev/null && \
      rm -f /tmp/lazygit.tar.gz || true
    msg_ok "Updated lazygit"
  fi

  if command -v zellij &>/dev/null; then
    msg_info "Updating zellij"
    curl -fsSL -o /tmp/zellij.tar.gz https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz &>/dev/null && \
      tar -xzf /tmp/zellij.tar.gz -C /usr/local/bin zellij &>/dev/null && \
      rm -f /tmp/zellij.tar.gz || true
    msg_ok "Updated zellij"
  fi

  if command -v starship &>/dev/null; then
    msg_info "Updating Starship Prompt"
    curl -fsSL -o /tmp/starship-install.sh https://starship.rs/install.sh &>/dev/null && \
      sh /tmp/starship-install.sh -y &>/dev/null && \
      rm -f /tmp/starship-install.sh || true
    msg_ok "Updated Starship Prompt"
  fi

  msg_info "Cleaning up"
  apt-get -y autoremove &>/dev/null
  apt-get -y autoclean &>/dev/null
  msg_ok "Cleaned up"

  msg_ok "Updated $APP LXC"
  exit
}

function description() {
  IP="${IP:-$(pct exec "$CTID" ip -4 addr show eth0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)}"
  CODE_PW=$(pct exec "$CTID" -- grep '^password:' /root/.config/code-server/config.yaml 2>/dev/null | awk '{print $2}')

  DESCRIPTION=$(cat <<EOF
<div align='center'>
  <a href='https://github.com/raddadengineer/Utilities' target='_blank' rel='noopener noreferrer'>
    <img src='https://raw.githubusercontent.com/community-scripts/core/main/images/logo-81x112.png' alt='Devbox' height='38' width='28' style='height:38px; width:auto;'/>
  </a>

  <h2 style='font-size: 20px; margin: 8px 0;'>${APP} LXC</h2>

  <p style='margin: 8px 0;'>
    <a href='http://${IP}:8080' target='_blank' rel='noopener noreferrer'>
      <img src='https://img.shields.io/badge/%F0%9F%9A%80_Web_IDE-Port_8080-00617f?style=for-the-badge' alt='Web IDE' />
    </a>
    <a href='http://${IP}:7681' target='_blank' rel='noopener noreferrer'>
      <img src='https://img.shields.io/badge/%F0%9F%92%BB_Terminal-Port_7681-2ea043?style=for-the-badge' alt='Web Terminal' />
    </a>
  </p>

  <p style='margin: 6px 0; font-size: 13px;'>
    <strong>Web IDE:</strong> <a href='http://${IP}:8080' target='_blank'>http://${IP}:8080</a><br/>
    <strong>Web Terminal:</strong> <a href='http://${IP}:7681' target='_blank'>http://${IP}:7681</a><br/>
    <strong>Default Credentials:</strong> User: <code>root</code> &nbsp;|&nbsp; Password: <code>${CODE_PW:-devbox}</code>
  </p>

  <span style='margin: 0 8px;'>
    <a href='https://github.com/raddadengineer/Utilities/tree/main/devbox' target='_blank' rel='noopener noreferrer' style='text-decoration: none; color: #00617f;'>📖 Documentation</a>
  </span>
  <span style='margin: 0 8px;'>
    <a href='https://github.com/raddadengineer/Utilities' target='_blank' rel='noopener noreferrer' style='text-decoration: none; color: #00617f;'>💻 GitHub Repository</a>
  </span>
</div>
EOF
)
  pct set "$CTID" -description "$DESCRIPTION"
}

start
build_container
description

CODE_PW=$(pct exec "$CTID" -- grep '^password:' /root/.config/code-server/config.yaml 2>/dev/null | awk '{print $2}')
IP="${IP:-$(pct exec "$CTID" ip -4 addr show eth0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)}"

msg_ok "Completed Successfully!\n"
echo -e "${APP} Services:
  - Web IDE:      ${BL}http://${IP}:8080${CL}
  - Web Terminal: ${BL}http://${IP}:7681${CL} (User: ${GN}root${CL} / Password: ${GN}${CODE_PW:-devbox}${CL})

📱 iPad / Mobile PWA Setup:
   1. Open ${BL}http://${IP}:8080${CL} (IDE) or ${BL}http://${IP}:7681${CL} (CLI) in Safari.
   2. Tap the Share button (square with arrow up).
   3. Select 'Add to Home Screen'.
   4. Devbox launches full-screen as a standalone app!

To change credentials:
  - Web IDE:      ${BL}nano ~/.config/code-server/config.yaml${CL} && ${BL}systemctl restart code-server@root${CL}
  - Root / CLI:   ${BL}passwd root${CL}\n"

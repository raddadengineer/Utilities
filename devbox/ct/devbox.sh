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
  if ! command -v code-server &>/dev/null; then msg_error "No ${APP} Installation Found!"; exit; fi
  msg_info "Updating Base System"
  apt-get update &>/dev/null
  apt-get -y upgrade &>/dev/null
  msg_ok "Updated Base System"

  msg_info "Updating Browser IDE (code-server)"
  sh <(curl -fsSL https://code-server.dev/install.sh) &>/dev/null
  systemctl restart code-server@root
  msg_ok "Updated Browser IDE"

  if command -v npm &>/dev/null; then
    msg_info "Updating Global NPM Packages"
    npm update -g &>/dev/null || true
    msg_ok "Updated Global NPM Packages"
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
    systemctl restart ttyd 2>/dev/null || true
    msg_ok "Updated Web Terminal (ttyd)"
  fi

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
  - Web Terminal: ${BL}nano /etc/systemd/system/ttyd.service${CL} && ${BL}systemctl daemon-reload && systemctl restart ttyd${CL}\n"

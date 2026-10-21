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

  msg_ok "Updated $APP LXC"
  exit
}

start
build_container
description

CODE_PW=$(pct exec "$CTID" -- grep '^password:' /root/.config/code-server/config.yaml 2>/dev/null | awk '{print $2}')
IP="${IP:-$(pct exec "$CTID" ip -4 addr show eth0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)}"

msg_ok "Completed Successfully!\n"
echo -e "${APP} Web IDE: ${BL}http://${IP}:8080${CL}
Password: ${GN}${CODE_PW:-devbox}${CL}

📱 iPad / Mobile PWA Setup:
   1. Open ${BL}http://${IP}:8080${CL} in Safari on your iPad or phone.
   2. Tap the Share button (square with arrow up).
   3. Select 'Add to Home Screen'.
   4. Devbox launches full-screen with captured desktop shortcuts!

To change the Web IDE password:
  1. Inside container: ${TAB}${BL}nano ~/.config/code-server/config.yaml${CL}
  2. Update the 'password:' value
  3. Restart service: ${TAB}${BL}systemctl restart code-server@root${CL}\n"

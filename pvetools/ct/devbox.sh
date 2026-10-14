#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
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
var_disk="40"
var_cpu="4"
var_ram="4096"
var_os="ubuntu"
var_version="24.04"
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
  FEATURES="nesting=1,keyctl=1" 
  echo_default
}

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -f /etc/systemd/system/code-server@root.service ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  msg_info "Updating $APP LXC"
  apt-get update &>/dev/null
  apt-get -y upgrade &>/dev/null
  msg_ok "Updated $APP LXC"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8080${CL} \n"

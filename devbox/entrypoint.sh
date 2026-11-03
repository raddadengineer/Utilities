#!/usr/bin/env bash
set -e

# Default password devbox or from environment
DEVBOX_PW="${PASSWORD:-${CODE_SERVER_PASSWORD:-devbox}}"

mkdir -p /home/devbox/.config/code-server
if [ "$DEVBOX_PW" = "none" ] || [ -z "$DEVBOX_PW" ]; then
  cat <<EOF > /home/devbox/.config/code-server/config.yaml
bind-addr: 0.0.0.0:8080
auth: none
cert: false
EOF
else
  cat <<EOF > /home/devbox/.config/code-server/config.yaml
bind-addr: 0.0.0.0:8080
auth: password
password: ${DEVBOX_PW}
cert: false
EOF
fi

# Ensure workspace exists
mkdir -p /home/devbox/workspace

# Handle docker socket permissions if mounted from host
if [ -S /var/run/docker.sock ]; then
  SOCK_GID=$(stat -c '%g' /var/run/docker.sock 2>/dev/null || stat -f '%g' /var/run/docker.sock 2>/dev/null || true)
  if [ -n "$SOCK_GID" ] && [ "$SOCK_GID" != "0" ]; then
    if ! getent group "$SOCK_GID" >/dev/null 2>&1; then
      sudo groupadd -g "$SOCK_GID" host-docker 2>/dev/null || true
    fi
    sudo usermod -aG "$SOCK_GID" devbox 2>/dev/null || true
  fi
fi

exec "$@"

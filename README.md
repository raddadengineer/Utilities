# 🛠️ Utility Scripts Collection

This repository contains a set of scripts and utilities for network automation, VLAN setup on Asuswrt-Merlin routers, Proxmox GPU passthrough, and fleet management with Cockpit. Each directory targets a specific use case or device.

---

## 📂 Directory Overview

### `asuswrt-merlin/vlan-setup/`
Scripts for configuring VLANs and Wi-Fi bridges on Asus routers running Asuswrt-Merlin firmware. Each subdirectory targets a specific router model:

- **AC3100, AC68U, AC55, AX11000**:  
  - `*.sh`: Main VLAN and bridge setup scripts for each model.
  - `aimesh-vlan-bridge.sh`: VLAN bridge script for AiMesh nodes.
  - `services-start`: Boot hook to auto-run scripts at startup.
  - `README.md`: Model-specific setup instructions.

These scripts automate:
- VLAN interface creation and bridge mapping
- NVRAM updates for persistent configuration
- Safe detachment/cleanup of old interfaces
- Guest Wi-Fi isolation and AP mode bridging

---

### `cockpit/`
Automated deployment of [Cockpit](https://cockpit-project.org/) across multiple Linux hosts.

- **cockpit-fleet.sh**:  
  - Distributes SSH keys and installs Cockpit on a fleet of servers.
  - Supports parallel execution and detailed logging.
  - CLI flags for flexible operation (`--keys-only`, `--install-only`, `--parallel`).
- **README.md**:  
  - Usage instructions, requirements, and advanced tips.

---

### `Prox-GPU/`
Guides and snippets for enabling GPU passthrough in Proxmox LXC containers.

- **Readme.md**:  
  - Step-by-step instructions for host and container setup.
  - Covers driver installation, cgroup configuration, and NVIDIA Container Toolkit.

---

### `devbox/`
Automated Proxmox VE helper scripts and container templates.

- **`ct/devbox.sh` & `install/devbox-install.sh`**:
  - Deploys an unprivileged Ubuntu 24.04 AI Devbox LXC container.
  - Pre-loaded with Docker, Node.js, Python/uv, browser IDE (code-server), Starship, modern CLI tools (zellij, eza, bat, ripgrep, fzf, lazydocker, lazygit), and AI coding agents (Antigravity CLI, Claude Code, Gemini CLI, OpenCode, Aider).
- **README.md**:
  - Quick-start instructions, container specs, software stack, and password configuration.

---

## 🚀 Getting Started

1. **Asuswrt-Merlin VLAN Setup**  
   - Pick your router model under `asuswrt-merlin/vlan-setup/`.
   - Follow the included `README.md` for prerequisites and deployment steps.
   - Scripts are designed for safe, repeatable VLAN and bridge configuration.

2. **Cockpit Fleet Installer**  
   - See `cockpit/README.md` for usage.
   - Run `cockpit-fleet.sh` to automate Cockpit deployment across your Linux fleet.

3. **Proxmox GPU Passthrough**  
   - Follow `Prox-GPU/Readme.md` for enabling GPU access in LXC containers.

4. **Proxmox Devbox LXC**  
   - Run `bash -c "$(curl -fsSL https://raw.githubusercontent.com/raddadengineer/Utilities/main/devbox/ct/devbox.sh)"` on your Proxmox host.
   - See `devbox/README.md` for complete configuration and tool references.

---

## 🧩 Contributions

Pull requests and suggestions are welcome! Please document new scripts and keep instructions clear for future users.

---

## 👨‍💻 Maintainer

Infra automation specialist, Proxmox power-user, and homelab tinkerer.

---
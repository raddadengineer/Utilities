# 📦 Proxmox VE Devbox LXC

Automated deployment of an AI-ready developer environment in an unprivileged Ubuntu 24.04 LXC container on Proxmox VE.

---

## 🚀 Quick Start

Run the following command in your Proxmox VE shell (Host Node):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/raddadengineer/Utilities/main/devbox/ct/devbox.sh)"
```

Or using `wget`:

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/raddadengineer/Utilities/main/devbox/ct/devbox.sh)"
```

---

## ⚙️ Container Specifications

| Setting | Default Value | Notes |
| :--- | :--- | :--- |
| **OS** | Ubuntu 24.04 (Noble) | Standard LXC template |
| **Type** | Unprivileged (`CT_TYPE="1"`) | Safe multi-tenant container |
| **CPU** | 4 Cores | Configurable during setup |
| **RAM** | 4096 MB | Configurable during setup |
| **Disk** | 40 GB | Configurable during setup |
| **Features** | `nesting=1,keyctl=1` | Required for Docker and container tools |
| **Web IDE Port** | `8080` | [code-server](https://github.com/coder/code-server) |
| **Default Password** | `devbox` (or container password) | Changeable in config |

---

## 🧰 Included Software Stack

### 1. Browser IDE
- **[code-server](https://github.com/coder/code-server)**: Full VS Code environment accessible directly via web browser at `http://<CONTAINER_IP>:8080`.

### 2. AI Coding Agents
- **[Antigravity CLI (`agy`)](https://antigravity.google)**: Google's AI agent coding CLI (`/usr/local/bin/agy`).
- **[Claude Code (`claude`)](https://github.com/anthropics/claude-code)**: Anthropic's terminal agent (`@anthropic-ai/claude-code`).
- **[Gemini CLI (`gemini`)](https://github.com/google-gemini/gemini-cli)**: Google Gemini CLI (`@google/gemini-cli`).
- **[OpenCode (`opencode`)](https://opencode.ai)**: Terminal agent and workflow tool.
- **[Aider (`aider`)](https://aider.chat)**: AI pair programming in the terminal.

### 3. Container & Runtime Tools
- **Docker CE & Docker Compose**: Full container runtime configured with LXC nesting support.
- **Node.js 20.x LTS & npm**: Core JavaScript runtime for agents and web tools.
- **Python 3 & [uv](https://astral.sh/uv)**: Blazing-fast Python package and project manager.
- **pipx**: Isolated CLI tool installer.

### 4. Modern CLI & Productivity Stack
- **[zellij](https://zellij.dev/)**: Terminal workspace and multiplexer.
- **[eza](https://github.com/eza-community/eza)**: Modern replacement for `ls` with icons and git status.
- **[bat](https://github.com/sharkdp/bat)**: Syntax-highlighting `cat` clone (`bat`).
- **[ripgrep (`rg`)](https://github.com/BurntSushi/ripgrep)** & **[fd (`fd`)](https://github.com/sharkdp/fd)**: High-speed search utilities.
- **[zoxide (`z`)](https://github.com/ajeetdsouza/zoxide)**: Smarter `cd` directory jumper.
- **[fzf](https://github.com/junegunn/fzf)**: Command-line fuzzy finder.
- **[btop](https://github.com/aristocratos/btop)**: Resource and process monitor.
- **[Starship](https://starship.rs/)**: Fast, customizable shell prompt.
- **[lazydocker](https://github.com/jesseduffield/lazydocker)** & **[lazygit](https://github.com/jesseduffield/lazygit)**: Terminal UIs for Docker and Git.

---

## 🔐 Credentials & Password Management

### Default Credentials
- **Console / SSH User**: `root`
- **Auto-Login**: Enabled on Proxmox xterm.js Web GUI console and standard container TTY.
- **Web IDE URL**: `http://<CONTAINER_IP>:8080`
- **Web IDE Password**: `devbox` (or the password set during container creation).

### How to Change the Web IDE Password
Inside the container, run:

1. Edit the configuration file:
   ```bash
   nano ~/.config/code-server/config.yaml
   ```
2. Update the `password:` field with your desired password:
   ```yaml
   bind-addr: 0.0.0.0:8080
   auth: password
   password: <your-new-password>
   cert: false
   ```
3. Restart the service:
   ```bash
   systemctl restart code-server@root
   ```

---

## 🔄 Updating Devbox

To update an existing Devbox container, re-run the script in your Proxmox VE shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/raddadengineer/Utilities/main/devbox/ct/devbox.sh)"
```

Select **YES** to run the update routine, which updates:
- System packages (`apt-get upgrade`)
- Browser IDE (`code-server`)
- Global npm agents (`@anthropic-ai/claude-code`, `@google/gemini-cli`)

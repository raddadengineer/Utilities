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
| **Web IDE Port** | `8080` | [code-server](https://github.com/coder/code-server) (VS Code in browser) |
| **Web Terminal Port** | `7681` | [ttyd](https://github.com/tsl0922/ttyd) (Mobile-optimized web CLI) |
| **Default Credentials** | User: `root` / Pass: `devbox` | Changeable in service configs |

---

## 🧰 Included Software Stack & Tool Reference

### 1. Browser IDE, Web CLI & Mobile Development
| Tool / Component | Command / Path | Purpose |
| :--- | :--- | :--- |
| **[code-server](https://github.com/coder/code-server)** | `code-server` (port 8080) | Full VS Code in the browser accessible at `http://<IP>:8080`, tuned for iPad PWA and mobile touch |
| **[ttyd](https://github.com/tsl0922/ttyd)** | `ttyd` (port 7681) | Fast, lightweight web-based terminal accessible at `http://<IP>:7681` with mobile canvas rendering, authentication, and dark theme |
| **Mobile PWA Tuning** | `~/.local/share/code-server/User/settings.json` | Pre-configured with auto-save, word wrap, smooth inertia touch scrolling, and disabled minimap for tablet/phone screens |

#### Pre-installed VS Code Extensions
| Extension ID | Name | Purpose |
| :--- | :--- | :--- |
| `ms-python.python` | Python | Rich Python language support, debugging, virtualenv detection, and code intelligence |
| `esbenp.prettier-vscode` | Prettier | Universal opinionated code formatting for JS, TS, HTML, CSS, JSON, Markdown |
| `eamodio.gitlens` | GitLens | Visual Git history, line-by-line blame annotations, and repository exploration |
| `usernamehw.errorlens` | ErrorLens | Inline diagnostic error and warning highlighting (no mouse hover needed on touchscreens) |
| `redhat.vscode-yaml` | YAML | Schema validation, autocompletion, and hover documentation for Docker and Kubernetes files |

### 2. AI Coding Agents
| Agent / Assistant | Command | Purpose |
| :--- | :--- | :--- |
| **[Antigravity CLI](https://antigravity.google)** | `agy` | Google's agentic AI coding CLI with subagent orchestration and automated workflows |
| **[Claude Code](https://github.com/anthropics/claude-code)** | `claude` | Anthropic's agentic terminal assistant for searching codebases, editing files, and running commands |
| **[Gemini CLI](https://github.com/google-gemini/gemini-cli)** | `gemini` | Google Gemini CLI assistant for terminal-based prompt queries and code generation |
| **[OpenCode](https://opencode.ai)** | `opencode` | AI-native terminal pair programmer and multi-model workflow orchestrator |
| **[Aider](https://aider.chat)** | `aider` | Git-integrated AI pair programmer for terminal-based interactive editing and auto-commits |

### 3. Container & Runtime Tools
| Tool / Runtime | Command | Purpose |
| :--- | :--- | :--- |
| **Docker CE** | `docker` | Container engine with LXC nesting support for building and running containers |
| **Docker Compose** | `docker compose` | Multi-container application orchestrator |
| **Node.js 20 LTS** | `node`, `npm` | Core JavaScript runtime for web development and AI agent packages |
| **Python 3** | `python3`, `pip` | Core Python 3 environment with `pip` and virtual environment support |
| **[uv](https://astral.sh/uv)** | `uv`, `uvx` | Ultra-fast Rust-based Python package resolver, installer, and virtualenv manager |
| **pipx** | `pipx` | Isolated CLI tool installer for running Python applications in sandboxed environments |

### 4. Modern CLI & Productivity Stack
| Tool | Command / Alias | Purpose |
| :--- | :--- | :--- |
| **[GitHub CLI](https://cli.github.com/)** | `gh` | Official GitHub CLI with frictionless browser device-code authentication (`gh auth login --web`) |
| **[micro](https://micro-editor.github.io/)** | `micro` (default `$EDITOR`) | Touchscreen-friendly terminal text editor (supports tap-to-place cursor, touch scrolling, and standard shortcuts) |
| **[zellij](https://zellij.dev/)** | `zellij` | Rust-based terminal workspace manager, session multiplexer, and floating layout engine |
| **[eza](https://github.com/eza-community/eza)** | `eza` (aliased to `ls`, `ll`) | Modern replacement for `ls` with color-coded icons, file metadata, and Git status |
| **[bat](https://github.com/sharkdp/bat)** | `bat` (aliased to `cat`) | Syntax-highlighting `cat` clone with line numbers and Git modification markers |
| **[ripgrep](https://github.com/BurntSushi/ripgrep)** | `rg` (aliased to `grep`) | Ultra-fast recursive line-oriented regex search utility |
| **[fd](https://github.com/sharkdp/fd)** | `fd` (aliased to `find`) | User-friendly, fast alternative to `find` with colorized output and regex support |
| **[zoxide](https://github.com/ajeetdsouza/zoxide)** | `z` (aliased to `cd`) | Smarter `cd` command that learns your most frequent directories |
| **[fzf](https://github.com/junegunn/fzf)** | `fzf` | Interactive command-line fuzzy finder for files, history, and processes |
| **[btop](https://github.com/aristocratos/btop)** | `btop` | Terminal-based resource monitor displaying CPU, memory, disks, network, and processes |
| **[Starship](https://starship.rs/)** | Prompt | Minimal, blazing-fast shell prompt displaying Git branch, language runtimes, and status |
| **[lazydocker](https://github.com/jesseduffield/lazydocker)** | `lazydocker` | Terminal UI for managing Docker containers, images, logs, and volumes |
| **[lazygit](https://github.com/jesseduffield/lazygit)** | `lazygit` | Terminal UI for Git commands, diffing, staging hunks, and managing branches |
| **jq** | `jq` | Lightweight and flexible command-line JSON processor |

---

## 📱 iPad & Mobile Setup

### 1. PWA Standalone Mode (Add to Home Screen)
Turn the Web IDE and Web Terminal into dedicated full-screen apps on your iPad or iPhone:

1. Open `http://<CONTAINER_IP>:8080` (IDE) or `http://<CONTAINER_IP>:7681` (CLI) in **Safari**.
2. Tap the **Share** button (box with upward arrow).
3. Tap **Add to Home Screen**.
4. Open the app icon from your Home Screen:
   - Runs in borderless full-screen without the Safari address bar or bottom tab strip.
   - Captures desktop keyboard shortcuts (`Cmd+P`, `Cmd+W`, `Ctrl+C`).
   - Supports native iPadOS trackpad and mouse gestures.

### 2. Customizing `ttyd` for Mobile Screens
You can customize the Web Terminal's appearance dynamically or persistently:

* **Dynamic Screen-Size Adjustment via URL Parameters**:
  * On a phone: `http://<CONTAINER_IP>:7681/?fontSize=16`
  * On an iPad: `http://<CONTAINER_IP>:7681/?fontSize=14`
  * High-res monitor: `http://<CONTAINER_IP>:7681/?fontSize=18`
* **Mobile-Optimized Service Flags** (configured in `/etc/systemd/system/ttyd.service`):
  * `login` (Native PAM authentication): Uses the standard Linux terminal `login` prompt instead of HTTP Basic Auth (`-c`), avoiding iOS/iPadOS Safari's `NSURLSession` WebSocket Basic Auth drop bug (`Press Enter to Reconnect`).
  * `-P 5`: Sends WebSocket ping heartbeats every 5 seconds to keep mobile connections alive.
  * `fontSize=15`: Crisp, legible default for mobile viewports.
  * `rendererType=canvas`: Uses HTML5 2D canvas instead of WebGL, reducing memory consumption and preventing iOS Safari WebKit tab reloads.
  * `theme={...}`: High-contrast modern dark palette with clean cursor visibility.
* **Auto-Launch Zellij**: To have `ttyd` automatically attach to a persistent Zellij session on connect, edit `/etc/systemd/system/ttyd.service` and replace `login` with `zellij attach -c devbox`.

---

## 🔐 Credentials & Password Management

### Default Credentials
- **Console / SSH User**: `root`
- **Auto-Login**: Enabled on Proxmox xterm.js Web GUI console and standard container TTY.
- **Web IDE URL**: `http://<CONTAINER_IP>:8080` (Password: `devbox` or container password)
- **Web Terminal URL**: `http://<CONTAINER_IP>:7681` (Terminal `login:` `root` / Password: `devbox` or container password)

### How to Change Credentials
Inside the container, run:

1. **Change Web IDE Password**:
   ```bash
   nano ~/.config/code-server/config.yaml
   # Update 'password:', then restart:
   systemctl restart code-server@root
   ```
2. **Change Root / Web Terminal (ttyd) & SSH Password**:
   ```bash
   passwd root
   ```

---

## 🔄 Updating Devbox

### How to Run Updates

Updates run **inside the container**. You can trigger the update routine using either of two methods:

#### Method 1: Inside the Container (Recommended)
Open your terminal (via Web Terminal at `http://<IP>:7681`, Proxmox Console, or SSH) and run:

```bash
update
```

*(You can also re-run the script directly inside the container:* `bash -c "$(curl -fsSL https://raw.githubusercontent.com/raddadengineer/Utilities/main/devbox/ct/devbox.sh)"`*)*

#### Method 2: From the Proxmox VE Host Shell
If you are logged into your Proxmox host shell, run the update into the container using `pct exec`:

```bash
pct exec <CTID> -- update
```

*(Replace `<CTID>` with your Devbox container ID, e.g. `107`).*

---

### What Gets Updated

The update routine comprehensively upgrades the entire software stack:

| Component Category | Tools Updated | Update Mechanism |
| :--- | :--- | :--- |
| **Base System & Security** | Ubuntu Noble packages, dependencies | `apt-get update && apt-get -y upgrade` |
| **Container & Runtimes** | Docker CE, Docker Compose, Node.js 20, Python 3 | Managed via official APT repositories |
| **Web Services** | [code-server](https://github.com/coder/code-server) (port 8080)<br>[ttyd](https://github.com/tsl0922/ttyd) (port 7681) | Upstream installer script & binary refresh + service restarts |
| **AI Coding Agents** | [Claude Code](https://github.com/anthropics/claude-code)<br>[Gemini CLI](https://github.com/google-gemini/gemini-cli)<br>[Aider](https://aider.chat)<br>[Antigravity CLI](https://antigravity.google) (`agy`)<br>[OpenCode](https://opencode.ai) | `npm update -g`<br>`npm update -g`<br>`pipx upgrade-all`<br>Official `agy` installer<br>`opencode upgrade` |
| **Modern CLI Stack** | [uv](https://astral.sh/uv)<br>[GitHub CLI](https://cli.github.com/) (`gh`)<br>[micro](https://micro-editor.github.io/)<br>[eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd), [zoxide](https://github.com/ajeetdsouza/zoxide), [fzf](https://github.com/junegunn/fzf), [btop](https://github.com/aristocratos/btop)<br>[zellij](https://zellij.dev/)<br>[lazydocker](https://github.com/jesseduffield/lazydocker)<br>[lazygit](https://github.com/jesseduffield/lazygit)<br>[Starship](https://starship.rs/) | `uv self update`<br>APT repository<br>APT / upstream<br>APT repositories<br><br>GitHub release binary<br>Upstream installer script<br>GitHub release binary<br>Upstream installer script |
| **System Hygiene** | Package cache & unused dependencies | `apt-get autoremove && apt-get autoclean` |

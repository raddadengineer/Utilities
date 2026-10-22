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

## 🧰 Included Software Stack & Tool Reference

### 1. Browser IDE & Mobile Development
| Tool / Component | Command / Path | Purpose |
| :--- | :--- | :--- |
| **[code-server](https://github.com/coder/code-server)** | `code-server` | Full VS Code in the browser accessible at `http://<IP>:8080`, tuned for iPad PWA and mobile touch |
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

## 📱 iPad / Mobile PWA Setup

Turn Devbox into a native full-screen app on your iPad or iPhone:

1. Open `http://<CONTAINER_IP>:8080` in **Safari**.
2. Tap the **Share** button (box with upward arrow).
3. Tap **Add to Home Screen**.
4. Open the **Devbox** icon from your Home Screen.
   - Runs full-screen without the Safari address bar or tab strip.
   - Captures desktop keyboard shortcuts (`Cmd+P`, `Cmd+Shift+P`, `Cmd+W`).
   - Automatically supports iPadOS trackpad and mouse gestures.

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

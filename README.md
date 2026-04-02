# bandit

A cross-platform terminal environment for [OverTheWire's Bandit wargame](https://overthewire.org/wargames/bandit/), powered by Podman.

Bandit teaches Linux command-line skills through a series of increasingly challenging SSH-based levels. This tool provides a consistent container environment with all the tools you need, plus local credential management so you never lose your progress.

---

## Requirements

- [Podman](https://podman.io/) 4.x+ (rootless)
- `jq` — for credential management on the host
- Bash 4+

### Platform notes

| Platform | Setup |
|---|---|
| Linux | Install Podman via your package manager (`dnf install podman` / `apt install podman`) |
| macOS | Install [Podman Desktop](https://podman-desktop.io/) or `brew install podman` |
| Windows | Install [Podman Desktop](https://podman-desktop.io/) with WSL2 backend; run from WSL2 or Git Bash |

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/clwilli/bandit.git
cd bandit

# 2. Build the container image (one-time setup, ~a minute)
./bandit init

# 3. Start at Level 0 (the password is publicly known)
./bandit connect 0

# 4. After solving a level, save the password you found
./bandit save 1 <password-you-found>

# 5. Connect to the next level
./bandit connect 1
```

---

## Commands

| Command | Description |
|---|---|
| `bandit init` | Build the container image (first-time setup) |
| `bandit connect <level>` | SSH into a level using the stored password |
| `bandit save <level> <pass>` | Save a level's password locally |
| `bandit status` | Show a progress table across all 34 levels |
| `bandit info <level>` | Show stored info and notes for a level |
| `bandit note <level> <text>` | Attach a personal note to a level |
| `bandit run <cmd> [args...]` | Run an arbitrary command inside the container |
| `bandit shell` | Open an interactive shell inside the container |
| `bandit reset` | Wipe all locally stored passwords and progress |
| `bandit version` | Print the version |
| `bandit help` | Show help text |

---

## How It Works

- All SSH connections run **inside a Podman container** that includes `sshpass`, `netcat`, `openssl`, `python3`, and all other tools commonly needed for Bandit challenges.
- **Passwords are stored locally** at `~/.local/share/bandit/` with restrictive permissions (600) and are never committed to this repository.
- The container uses `debian:bookworm-slim` as its base to match the glibc environment of the actual Bandit server.

---

## Tab Completion

```bash
# Bash
source completions/bandit.bash

# Zsh — add completions/ to your fpath, then:
fpath=(completions/ $fpath)
compinit

# Or source directly for the current session:
source completions/bandit.zsh
```

---

## Security

- No passwords are stored in this repository.
- Passwords are stored in `~/.local/share/bandit/` with `chmod 600` permissions.
- SSH passwords are passed to the container via environment variable (not command-line arguments) to keep them out of `ps aux` output.
- The container runs rootless and has no special host privileges.

---

## Contributing

Contributions are welcome — please open an issue or pull request.

**Important**: Do not commit passwords, level solutions, or hints. The `.gitignore` excludes `*.json` as a safety net. Any PR containing spoiler content will be closed.

---

## License

MIT

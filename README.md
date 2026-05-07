# macOS Dotfiles

![Version](https://img.shields.io/badge/version-v1.0.0-blue)

A reproducible macOS development environment using **symlinked dotfiles** and a **bootstrap script** to install tools, configure the shell, and set up terminal and editor settings automatically.

This repository allows you to configure a new Mac development environment in minutes.

---

## Version

Current stable release: **v1.0.0**

- Bootstrap script: v3
- Last tested on: macOS Tahoe 26.1

---

# Overview

This repository contains configuration files ("dotfiles") for:

- **Zsh** shell
- **Git**
- **Tmux**
- **Neovim**
- **WezTerm terminal**
- **Developer CLI tools**

A bootstrap script installs dependencies and creates symlinks from the home directory (`~`) to the files stored in this repository.

This approach ensures that:

- All configuration is version controlled
- New machines can be configured quickly
- Settings remain consistent across systems

---

# Supported System

Designed for:

- **macOS (Apple Silicon / ARM64)**
- macOS **12+ recommended**
- Default shell: **zsh**

The bootstrap script automatically installs **Homebrew** if it is not already present.

---

# Repository Structure

```
dotfiles
├─ zsh
│   ├─ .zshrc
│   └─ aliases.zsh
├─ git
│   └─ .gitconfig
├─ tmux
│   └─ .tmux.conf
├─ nvim
│   └─ init.lua
├─ wezterm
│   └─ wezterm.lua
└─ scripts
```
---

# What the Bootstrap Script Does

The bootstrap script performs the following tasks:

### 1. Creates Required Directory Structure

Ensures directories such as: ~/.config/nvim exist.

---

### 2. Creates Safe Symlinks

Symlinks your configuration files from the repository into your home directory.

Example:
```
~/.zshrc → ~/dotfiles/zsh/.zshrc
~/.gitconfig → ~/dotfiles/git/.gitconfig
~/.tmux.conf → ~/dotfiles/tmux/.tmux.conf
~/.wezterm.lua → ~/dotfiles/wezterm/wezterm.lua
~/.config/nvim/init.lua → ~/dotfiles/nvim/init.lua
```

Existing files are **backed up automatically**.

---

### 3. Installs Developer Tools via Homebrew

The following tools are installed:

| Tool | Purpose |
|-----|------|
| **neovim** | Modern Vim-based editor |
| **tmux** | Terminal multiplexer |
| **wezterm** | GPU accelerated terminal |
| **starship** | Cross-shell prompt |
| **zoxide** | Smart `cd` replacement |
| **fzf** | Fuzzy finder |
| **bat** | `cat` replacement |
| **eza** | Modern `ls` replacement |
| **git-delta** | Better Git diff viewer |
| **node** | Node.js runtime |
| **nvm** | Node Version Manager |

---

### 4. Installs Fonts

Installs:
JetBrainsMono Nerd Font


Required for icons and enhanced terminal rendering.

---

### 5. Installs Zsh Plugin Manager

Installs **Antidote** and loads plugins defined in:
.zsh_plugins.txt


Plugins include:

- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- `fzf`

---

# Installation

## 1. Clone the Repository

```bash
git clone https://github.com/marcovalvarez/dotfiles.git ~/dotfiles
```
## 2. Navigate to the Repository
```bash
cd ~/dotfiles
```
## 3. Make the Bootstrap Script Executable
```bash
chmod +x bootstrap.sh
```
## 4. Run the Bootstrap Script using bash
```bash
./bootstrap.sh
```
Or 
```bash
bash bootstrap.sh
```
## 5. Restart the Terminal
Or reload the shell:
```bash
source ~/.zshrc
```

# Verifying Installation

Check that symlinks exist:
```bash
ls -l ~/.zshrc
ls -l ~/.gitconfig
ls -l ~/.wezterm.lua
```

You should see output similar to:
```
.zshrc -> /Users/username/dotfiles/zsh/.zshrc
```

# Updating the Configuration
Edit configuration files directly in the repository.

Example:
```
~/dotfiles/zsh/.zshrc
```

Changes automatically apply because the files are symlinked.

# Updating Packages
Update installed packages using:

```bash
brew update
brew upgrade
```

# Re-running the Bootstrap Script
The bootstrap script is safe to run multiple times.

Existing configuration files will be backed up as:
`filename.backup`

# Customization
Common customizations include:

Adding Zsh plugins in .zsh_plugins.txt

Modifying terminal appearance in wezterm.lua

Extending Neovim configuration in init.lua

Adding aliases in `aliases.zsh`

# Recommended Workflow
Modify configuration

Commit changes
```bash
git add .
git commit -m "Update configuration"
git push
```

Your development environment can then be recreated on any new Mac.

# License
This repository is intended for personal configuration management but may be reused or adapted freely.


---

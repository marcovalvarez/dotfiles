#!/usr/bin/env bash

# =========================================================
# Idempotent Dotfiles Bootstrap (macOS/Linux)
# Includes: Homebrew, VS Code, chezmoi, stow
# Safe to run multiple times
# =========================================================

set -e

# =========================================================
# Variables
# =========================================================

DOTFILES="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"
FONT_DIR="${HOME}/Library/Fonts"

echo ""
echo "========================================="
echo "Dotfiles bootstrap starting..."
echo "========================================="
echo ""

# =========================================================
# Detect Homebrew
# =========================================================

if [[ -x "/opt/homebrew/bin/brew" ]]; then
    BREW_BIN="/opt/homebrew/bin/brew"
elif [[ -x "/usr/local/bin/brew" ]]; then
    BREW_BIN="/usr/local/bin/brew"
else
    BREW_BIN=""
fi

# =========================================================
# Ensure directories
# =========================================================

mkdir -p "${DOTFILES}"/{zsh,git,tmux,nvim,wezterm,scripts}
mkdir -p "${CONFIG_DIR}/nvim"
mkdir -p "${CONFIG_DIR}/wezterm"

# =========================================================
# Ensure files
# =========================================================

[[ -f "${DOTFILES}/zsh/.zshrc" ]] || touch "${DOTFILES}/zsh/.zshrc"
[[ -f "${DOTFILES}/zsh/aliases.zsh" ]] || touch "${DOTFILES}/zsh/aliases.zsh"
[[ -f "${DOTFILES}/zsh/.zsh_plugins.txt" ]] || touch "${DOTFILES}/zsh/.zsh_plugins.txt"

[[ -f "${DOTFILES}/git/.gitconfig" ]] || touch "${DOTFILES}/git/.gitconfig"
[[ -f "${DOTFILES}/tmux/.tmux.conf" ]] || touch "${DOTFILES}/tmux/.tmux.conf"

[[ -f "${DOTFILES}/nvim/init.lua" ]] || echo "vim.opt.number = true" > "${DOTFILES}/nvim/init.lua"
[[ -f "${DOTFILES}/wezterm/wezterm.lua" ]] || echo "return {}" > "${DOTFILES}/wezterm/wezterm.lua"

# =========================================================
# Default plugins
# =========================================================

if [[ ! -s "${DOTFILES}/zsh/.zsh_plugins.txt" ]]; then
cat > "${DOTFILES}/zsh/.zsh_plugins.txt" <<EOF
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-autosuggestions
junegunn/fzf
EOF
fi

# =========================================================
# Symlinks (idempotent)
# =========================================================

echo "Creating symlinks..."

FILES=(
"${DOTFILES}/zsh/.zshrc:${HOME}/.zshrc"
"${DOTFILES}/zsh/aliases.zsh:${HOME}/.aliases.zsh"
"${DOTFILES}/zsh/.zsh_plugins.txt:${HOME}/.zsh_plugins.txt"
"${DOTFILES}/git/.gitconfig:${HOME}/.gitconfig"
"${DOTFILES}/tmux/.tmux.conf:${HOME}/.tmux.conf"
"${DOTFILES}/nvim/init.lua:${CONFIG_DIR}/nvim/init.lua"
"${DOTFILES}/wezterm/wezterm.lua:${CONFIG_DIR}/wezterm/wezterm.lua"
)

for file in "${FILES[@]}"; do

    src="${file%%:*}"
    dest="${file##*:}"

    mkdir -p "$(dirname "${dest}")"

    if [[ -L "${dest}" ]]; then
        current="$(readlink "${dest}")"
        if [[ "${current}" == "${src}" ]]; then
            echo "OK (already linked): ${dest}"
            continue
        else
            rm -f "${dest}"
        fi
    fi

    if [[ -e "${dest}" && ! -L "${dest}" ]]; then
        backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
        echo "Backing up ${dest}"
        mv "${dest}" "${backup}"
    fi

    ln -s "${src}" "${dest}"
    echo "Linked ${dest}"
done

# =========================================================
# Install Homebrew
# =========================================================

if [[ -z "${BREW_BIN}" ]]; then
    echo "Installing Homebrew..."

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        BREW_BIN="/opt/homebrew/bin/brew"
    else
        BREW_BIN="/usr/local/bin/brew"
    fi
fi

# =========================================================
# Brew shellenv (idempotent)
# =========================================================

if ! grep -q 'brew shellenv' "${HOME}/.zprofile" 2>/dev/null; then
cat >> "${HOME}/.zprofile" <<EOF

eval "$(${BREW_BIN} shellenv)"
EOF
fi

eval "$(${BREW_BIN} shellenv)"

# =========================================================
# Brew packages
# =========================================================

BREW_PACKAGES=(
git
neovim
tmux
wezterm
starship
zoxide
fzf
bat
eza
delta
node
nvm
ripgrep
fd
jq
)

echo "Installing brew packages..."

for pkg in "${BREW_PACKAGES[@]}"; do
    if "${BREW_BIN}" list "${pkg}" >/dev/null 2>&1; then
        echo "OK: ${pkg}"
    else
        echo "Installing ${pkg}"
        "${BREW_BIN}" install "${pkg}"
    fi
done

# =========================================================
# VS Code (idempotent)
# =========================================================

echo ""
echo "Installing VS Code..."

if ! "${BREW_BIN}" list --cask visual-studio-code >/dev/null 2>&1; then
    "${BREW_BIN}" install --cask visual-studio-code
else
    echo "VS Code already installed"
fi

# Enable CLI
VSCODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"

if [[ -f "${VSCODE_BIN}" ]]; then
    mkdir -p "${HOME}/.local/bin"
    ln -sf "${VSCODE_BIN}" "${HOME}/.local/bin/code"

    if ! grep -q '.local/bin' "${HOME}/.zshrc"; then
cat >> "${HOME}/.zshrc" <<EOF

export PATH="\$HOME/.local/bin:\$PATH"
EOF
    fi
fi

# =========================================================
# chezmoi (idempotent)
# =========================================================

echo ""
echo "Installing chezmoi..."

if ! command -v chezmoi >/dev/null 2>&1; then
    "${BREW_BIN}" install chezmoi
else
    echo "chezmoi already installed"
fi

# optional init (only if not already initialized)
if [[ ! -d "${HOME}/.local/share/chezmoi" ]]; then
    echo "Initializing chezmoi..."
    chezmoi init
fi
# =========================================================
# Fonts (idempotent)
# =========================================================

mkdir -p "${FONT_DIR}"

if [[ ! -f "${FONT_DIR}/JetBrainsMonoNerdFont-Regular.ttf" ]]; then

    TMP_ZIP="/tmp/font.zip"
    TMP_DIR="/tmp/font"

    curl -fLo "${TMP_ZIP}" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip

    unzip -o "${TMP_ZIP}" -d "${TMP_DIR}" >/dev/null
    cp "${TMP_DIR}"/*.ttf "${FONT_DIR}/"

    rm -rf "${TMP_ZIP}" "${TMP_DIR}"
fi

# =========================================================
# Antidote
# =========================================================

if [[ ! -d "${HOME}/.antidote" ]]; then
    git clone https://github.com/mattmc3/antidote.git "${HOME}/.antidote"
fi

# =========================================================
# NVM
# =========================================================

mkdir -p "${HOME}/.nvm"

if ! grep -q 'NVM_DIR' "${HOME}/.zshrc"; then
cat >> "${HOME}/.zshrc" <<EOF

export NVM_DIR="\$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
EOF
fi

# =========================================================
# Starship
# =========================================================

if ! grep -q 'starship init zsh' "${HOME}/.zshrc"; then
cat >> "${HOME}/.zshrc" <<EOF

eval "$(starship init zsh)"
EOF
fi

# =========================================================
# Done
# =========================================================

echo ""
echo "========================================="
echo "Bootstrap complete (idempotent)"
echo "========================================="
echo ""
echo "Restart terminal or run: source ~/.zshrc"
echo ""

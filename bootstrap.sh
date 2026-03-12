#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Variables
# -----------------------------
DOTFILES="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

echo "Starting dotfiles bootstrap..."

# -----------------------------
# Create folder structure if missing
# -----------------------------
echo "Ensuring dotfiles repo structure exists..."
mkdir -p "$DOTFILES"/{zsh,git,tmux,nvim,wezterm,scripts}
mkdir -p "$CONFIG_DIR/nvim"

# Placeholder files if missing
touch "$DOTFILES/nvim/init.lua"
touch "$DOTFILES/zsh/.zsh_plugins.txt"
touch "$DOTFILES/zsh/aliases.zsh"

# Default Antidote plugins
if [ ! -s "$DOTFILES/zsh/.zsh_plugins.txt" ]; then
    cat > "$DOTFILES/zsh/.zsh_plugins.txt" <<EOF
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-autosuggestions
junegunn/fzf
EOF
fi

# -----------------------------
# Symlink files safely
# -----------------------------
declare -A FILES
FILES=(
    ["$DOTFILES/zsh/.zshrc"]="$HOME/.zshrc"
    ["$DOTFILES/zsh/aliases.zsh"]="$HOME/.aliases.zsh"
    ["$DOTFILES/zsh/.zsh_plugins.txt"]="$HOME/.zsh_plugins.txt"
    ["$DOTFILES/git/.gitconfig"]="$HOME/.gitconfig"
    ["$DOTFILES/tmux/.tmux.conf"]="$HOME/.tmux.conf"
    ["$DOTFILES/nvim/init.lua"]="$CONFIG_DIR/nvim/init.lua"
    ["$DOTFILES/wezterm/wezterm.lua"]="$HOME/.wezterm.lua"
)

echo "Creating symlinks..."
for src in "${!FILES[@]}"; do
    dest="${FILES[$src]}"
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ] || [ -f "$dest" ]; then
        echo "Backing up existing $dest → $dest.backup"
        mv "$dest" "$dest.backup"
    fi
    ln -sf "$src" "$dest"
done

# -----------------------------
# Install Homebrew if missing
# -----------------------------
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# -----------------------------
# Install packages
# -----------------------------
BREW_PACKAGES=(
    starship zoxide fzf nvim delta bat eza tmux wezterm node nvm git
)

echo "Installing Homebrew packages..."
brew install "${BREW_PACKAGES[@]}" || true

# -----------------------------
# Install JetBrainsMono Nerd Font
# -----------------------------
FONT_DIR="$HOME/Library/Fonts"
JETBRAINS_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip"
if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    echo "Installing JetBrainsMono Nerd Font..."
    curl -L "$JETBRAINS_FONT_URL" -o /tmp/JetBrainsMono.zip
    unzip -o /tmp/JetBrainsMono.zip -d /tmp/jetbrainsfont
    cp /tmp/jetbrainsfont/*.ttf "$FONT_DIR/"
    rm -rf /tmp/JetBrainsMono.zip /tmp/jetbrainsfont
else
    echo "JetBrainsMono Nerd Font already installed, skipping."
fi

# -----------------------------
# Install Antidote
# -----------------------------
ANTIDOTE_DIR="$HOME/.antidote"
if [ ! -d "$ANTIDOTE_DIR" ]; then
    echo "Installing Antidote..."
    git clone https://github.com/mattmc3/antidote.git "$ANTIDOTE_DIR"
else
    echo "Antidote already installed."
fi

# -----------------------------
# Generate Antidote plugin cache (if missing)
# -----------------------------
ANTIDOTE_CACHE="$HOME/Library/Caches/antidote"
if [ ! -d "$ANTIDOTE_CACHE" ]; then
    echo "Generating Antidote plugin cache..."
    zsh -ic "source $ANTIDOTE_DIR/share/antidote/antidote.zsh; antidote load $HOME/.zsh_plugins.txt"
else
    echo "Antidote plugin cache already exists."
fi

# -----------------------------
# FZF setup
# -----------------------------
if [ -f "/opt/homebrew/opt/fzf/install" ]; then
    echo "Running FZF install script..."
    yes | /opt/homebrew/opt/fzf/install
fi

# -----------------------------
# NVM setup
# -----------------------------
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    \. "/opt/homebrew/opt/nvm/nvm.sh"
fi

# -----------------------------
# Starship prompt in .zshrc
# -----------------------------
if ! grep -q 'starship init zsh' "$HOME/.zshrc"; then
    echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
fi

# -----------------------------
# Verify symlinks
# -----------------------------
echo "Verifying symlinks..."
for src in "${!FILES[@]}"; do
    dest="${FILES[$src]}"
    if [ ! -L "$dest" ]; then
        echo "Warning: $dest is missing symlink!"
    else
        echo "OK: $dest → $(readlink "$dest")"
    fi
done

echo "Bootstrap complete! Please restart your terminal or run: source ~/.zshrc"
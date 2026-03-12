#!/usr/bin/env bash
set -e

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
mkdir -p "$DOTFILES"/{zsh,git,tmux,nvim,wezterm}

# Create placeholder files if missing
touch "$DOTFILES/nvim/init.lua"
touch "$DOTFILES/zsh/.zsh_plugins.txt"
touch "$DOTFILES/zsh/aliases.zsh"

# Default plugin list for Antidote
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

for src in "${!FILES[@]}"; do
    dest="${FILES[$src]}"
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ] || [ -f "$dest" ]; then
        echo "Backing up existing $dest to $dest.backup"
        mv "$dest" "$dest.backup"
    fi
    echo "Creating symlink $dest -> $src"
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

echo "Installing packages..."
brew install "${BREW_PACKAGES[@]}" || true

# -----------------------------
# Install JetBrainsMono Nerd Font
# -----------------------------
FONT_DIR="$HOME/Library/Fonts"
JETBRAINS_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip"

if ! ls "$FONT_DIR" | grep -q "JetBrainsMono Nerd Font"; then
    echo "Installing JetBrainsMono Nerd Font..."
    curl -L "$JETBRAINS_FONT_URL" -o /tmp/JetBrainsMono.zip
    unzip -o /tmp/JetBrainsMono.zip -d /tmp/jetbrainsfont
    cp /tmp/jetbrainsfont/*.ttf "$FONT_DIR/"
    rm -rf /tmp/JetBrainsMono.zip /tmp/jetbrainsfont
fi

# -----------------------------
# Setup Antidote for Zsh
# -----------------------------
if [ ! -d "$HOME/.antidote" ]; then
    echo "Installing Antidote..."
    git clone https://github.com/mattmc3/antidote.git "$HOME/.antidote"
fi

# -----------------------------
# FZF setup
# -----------------------------
if [ -f "/opt/homebrew/opt/fzf/install" ]; then
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
# Starship prompt
# -----------------------------
if ! grep -q 'starship init zsh' "$HOME/.zshrc"; then
    echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
fi

echo "Bootstrap complete! Restart terminal or run: source ~/.zshrc"

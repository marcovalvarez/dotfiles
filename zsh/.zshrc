# -----------------------------
# Use Neovim as default editor
# -----------------------------
export EDITOR=nvim
export VISUAL=nvim

# -----------------------------
# PATH additions
# -----------------------------
eval "$(/opt/homebrew/bin/brew shellenv)"

# -----------------------------
# Starship prompt
# -----------------------------
eval "$(starship init zsh)"

# -----------------------------
# zoxide (smart cd)
# -----------------------------
eval "$(zoxide init zsh)"

# -----------------------------
# FZF (fuzzy finder)
# -----------------------------
# Only source if fzf installed
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

# -----------------------------
# NVM (Node Version Manager)
# -----------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

# -----------------------------
# Antidote (Zsh plugin manager)
# -----------------------------
ANTIDOTE_DIR=$(brew --prefix antidote)/share/antidote
if [ -d "$ANTIDOTE_DIR" ]; then
    source "$ANTIDOTE_DIR/antidote.zsh"
    
    # Generate plugin cache if it doesn't exist
    ANTIDOTE_CACHE="$HOME/Library/Caches/antidote"
    if [ ! -d "$ANTIDOTE_CACHE" ]; then
        echo "Generating Antidote plugin cache..."
        antidote load ~/.zsh_plugins.txt
    fi
fi

# -----------------------------
# Aliases
# -----------------------------
if [ -f ~/.aliases.zsh ]; then
    source ~/.aliases.zsh
fi
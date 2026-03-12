# Use Neovim as default editor
export EDITOR=nvim
export VISUAL=nvim

eval "$(/opt/homebrew/bin/brew shellenv)"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"

source $(brew --prefix antidote)/share/antidote/antidote.zsh
antidote load ~/.zsh_plugins.txt

source ~/.aliases.zsh

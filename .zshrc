# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="robbyrussell"

# Ensure Oh My Zsh is loaded
source $ZSH/oh-my-zsh.sh

# Ensure zinit is installed and sourced
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download zinit if it doesn't exist
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-completions  # Additional Zsh completions
zinit light zsh-users/zsh-autosuggestions  # Command autosuggestions
zinit light Aloxaf/fzf-tab  # FZF tab completion

# Load zsh snippets
zinit snippet OMZP::git  # Git commands
zinit snippet OMZP::sudo  # Sudo commands
zinit snippet OMZP::kubectl  # Kubectl commands
zinit snippet OMZP::kubectx  # Kubectx commands
zinit snippet OMZP::command-not-found  # Handle command not found

# Ensure kubectl is installed
if ! command -v kubectl &> /dev/null; then
  echo "kubectl not found, installing..."
  curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/$(uname | tr '[:upper:]' '[:lower:]')/amd64/kubectl"
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
fi

# Ensure fzf is installed
if ! command -v fzf &> /dev/null; then
  echo "fzf not found, installing..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
fi

# Ensure other tools are installed as needed
# Add similar checks for other tools you need

# Load completions
autoload -Uz compinit && compinit

# History settings
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
  # Use Neovim for vimdkey -M vicmd 'b' backward-word
bindkey -M vicmd 'e' end-of-word
bindkey -M vicmd '^' beginning-of-line
bindkey -M vicmd '$' end-of-line
bindkey -M vicmd '0' beginning-of-line
bindkey -M vicmd 'G' end-of-buffer-or-history
bindkey -M vicmd 'gg' beginning-of-buffer-or-history
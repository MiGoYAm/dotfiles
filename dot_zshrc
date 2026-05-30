# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

POWERLEVEL9K_MODE=ascii
POWERLEVEL9K_DISABLE_HOT_RELOAD=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_INSTANT_PROMPT=quiet

# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' special-dirs false
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*:git-checkout:*' sort false
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1A --color=always $realpath'
# zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1A --color=always $realpath'
zstyle ':fzf-tab:complete:*:options' fzf-preview
zstyle ':fzf-tab:complete:*:argument-1' fzf-preview
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept

setopt globdots

HISTSIZE=5000
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory # share history across zsh sessions
setopt hist_ignore_space # ignore commands that start with space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

export FZF_DEFAULT_OPTS='--no-separator --info=inline-right'

source "$(brew --prefix antidote)/share/antidote/antidote.zsh"
zsh_config_dir=~
antidote load "${zsh_config_dir}/.zsh_plugins.txt" "${zsh_config_dir}/.zsh_plugins.zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias ls="eza"

eval "$(zoxide init --cmd cd zsh)"
eval "$(fzf --zsh)"
eval "$(mise activate zsh)"
eval "$(wt config shell init zsh)" 

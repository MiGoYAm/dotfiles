#!/usr/bin/env bash

set -euo pipefail

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/MiGoYAm/dotfiles.git}"
REPO_BRANCH="${DOTFILES_REPO_BRANCH:-main}"
ARCHIVE_URL="https://github.com/MiGoYAm/dotfiles/archive/refs/heads/${REPO_BRANCH}.tar.gz"
DEST_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

log() {
  printf '==> %s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

load_brew_env() {
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
    return
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return
  fi

  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    return
  fi

  die "Homebrew is installed but brew is still unavailable"
}

ensure_repo() {
  if [[ -d "$DEST_DIR/.git" ]]; then
    if ! command -v git >/dev/null 2>&1; then
      die "git is required to update an existing dotfiles checkout"
    fi

    log "Updating existing repo in $DEST_DIR"
    git -C "$DEST_DIR" pull --ff-only
    return
  fi

  if [[ -e "$DEST_DIR" ]] && [[ -n "$(ls -A "$DEST_DIR" 2>/dev/null)" ]]; then
    die "$DEST_DIR already exists and is not an empty dotfiles checkout"
  fi

  mkdir -p "$DEST_DIR"

  if command -v git >/dev/null 2>&1; then
    log "Cloning repo into $DEST_DIR"
    git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$DEST_DIR"
    return
  fi

  log "Downloading repo archive into $DEST_DIR"
  curl -fsSL "$ARCHIVE_URL" | tar -xzf - --strip-components=1 -C "$DEST_DIR"
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    load_brew_env
    return
  fi

  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_brew_env
}

install_brew_bundle() {
  local brewfile_path
  brewfile_path="$DEST_DIR/Brewfile"
  log "Installing packages from $(basename "$brewfile_path")"
  brew bundle --file="$brewfile_path"
}

ensure_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    return
  fi

  log "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

sync_git_repo() {
  local repo_url destination
  repo_url="$1"
  destination="$2"

  if [[ -d "$destination/.git" ]]; then
    log "Updating $(basename "$destination")"
    git -C "$destination" pull --ff-only || warn "could not update $destination"
    return
  fi

  if [[ -e "$destination" ]]; then
    warn "$destination exists and is not a git checkout; leaving it untouched"
    return
  fi

  log "Cloning $(basename "$destination")"
  git clone --depth 1 "$repo_url" "$destination"
}

install_zsh_addons() {
  local custom_dir
  custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  mkdir -p "$custom_dir/themes" "$custom_dir/plugins"

  sync_git_repo "https://github.com/romkatv/powerlevel10k.git" "$custom_dir/themes/powerlevel10k"
  sync_git_repo "https://github.com/Aloxaf/fzf-tab.git" "$custom_dir/plugins/fzf-tab"
  sync_git_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$custom_dir/plugins/zsh-autosuggestions"
  sync_git_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$custom_dir/plugins/zsh-syntax-highlighting"
  sync_git_repo "https://github.com/zsh-users/zsh-completions.git" "$custom_dir/plugins/zsh-completions"
}

apply_stow() {
  local parent_dir package_name
  parent_dir="$(dirname "$DEST_DIR")"
  package_name="$(basename "$DEST_DIR")"

  log "Symlinking dotfiles into $HOME"
  stow --target="$HOME" --dir="$parent_dir" --stow "$package_name"
}

main() {
  ensure_repo
  ensure_homebrew
  install_brew_bundle
  ensure_oh_my_zsh
  install_zsh_addons
  apply_stow

  log "Done. Restart your shell or run: exec zsh"
}

main "$@"

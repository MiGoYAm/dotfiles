# dotfiles

Personal shell, editor, and CLI setup managed with chezmoi and Homebrew.

## Install

```bash
git clone https://github.com/MiGoYAm/dotfiles.git ~/dotfiles
chezmoi init --source ~/dotfiles --apply
```

## Zsh plugins

Zsh plugins are declared in `.zsh_plugins.txt` and loaded through [Antidote](https://github.com/mattmc3/antidote). The generated `.zsh_plugins.zsh` file is built on demand by `.zshrc`.

## Re-running

Re-running `chezmoi apply --source ~/dotfiles` refreshes Homebrew packages and re-applies chezmoi-managed files.

## Todo
[ ] Add host on ssh to shell prompt

# dotfiles

Personal shell, editor, and CLI setup managed with GNU Stow and Homebrew.

## Quick install

Run the installer with:

```bash
curl -fsSL https://raw.githubusercontent.com/MiGoYAm/dotfiles/main/install.sh | bash
```

The script:

- clones or updates the repo in `~/dotfiles`
- installs Homebrew if needed
- installs packages from `Brewfile`
- installs Antidote for the Zsh plugin setup used by `.zshrc`
- symlinks the repo into `$HOME` with GNU Stow

## Manual install

If you want to run the steps yourself:

```bash
git clone https://github.com/MiGoYAm/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Zsh plugins

Zsh plugins are declared in `.zsh_plugins.txt` and loaded through [Antidote](https://github.com/mattmc3/antidote). The generated `.zsh_plugins.zsh` file is built on demand by `.zshrc`.

## Re-running

The installer is designed to be idempotent. Re-running it updates the repo, refreshes Homebrew packages, and re-applies Stow links.

## Todo
[ ] Add host on ssh to shell prompt

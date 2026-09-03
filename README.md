# dotfiles

Personal shell, editor, and CLI setup managed with **mise bootstrap**

## Install

```bash
curl https://mise.run | sh

mise bootstrap --from https://github.com/MiGoYAm/dotfiles.git --yes
```

## Re-running

```bash
mise bootstrap status --missing
mise bootstrap dotfiles status
mise bootstrap packages status
mise bootstrap macos defaults status
mise bootstrap mise-shell-activate status

mise bootstrap --force-dotfiles --yes
mise bootstrap --skip repos --force-dotfiles
mise bootstrap dotfiles apply --force --yes
```

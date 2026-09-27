# zsh-custom

A small, safe, upgradeable zsh configuration for teams, built on
[chezmoi](https://www.chezmoi.io) (distribution), [antidote](https://antidote.sh)
(plugins), and [Starship](https://starship.rs) (prompt). Linux and macOS.

## Install

```sh
git clone https://github.com/fredleb/zsh-custom.git ~/.zsh-custom
~/.zsh-custom/install.sh
exec zsh
```

`install.sh` verifies that chezmoi, antidote, and Starship are installed (and
prints the command to install any that are missing), then applies this
configuration with chezmoi. On the first apply your existing shell files are
backed up to `~/.zshrc.pre-chezmoi`, etc.

## Requirements

- zsh >= 5.4
- chezmoi, antidote, and Starship installed with your package manager:

| Platform | chezmoi | antidote | Starship |
|---|---|---|---|
| macOS (Homebrew) | `brew install chezmoi` | `brew install antidote` | `brew install starship` |
| Arch | `sudo pacman -S chezmoi` | `yay -S zsh-antidote` | `sudo pacman -S starship` |
| Debian/Ubuntu | `sudo apt-get install chezmoi` | `sudo apt-get install zsh-antidote` | `sudo apt-get install starship` |

The configuration never installs packages and never runs `sudo`.

## Daily commands

```sh
chezmoi update     # pull the latest configuration and apply it
chezmoi diff       # preview what would change
chezmoi status     # show drift from the managed configuration
chezmoi doctor     # diagnose problems
```

## What is managed

`~/.zshenv`, `~/.zshrc`, `~/.config/zsh/**`, and `~/.config/starship.toml`.
Everything else in your home directory is left alone.

## Customize

Personal configuration lives in untracked files that updates never touch:

| File | Purpose |
|---|---|
| `~/.config/zsh/local.zsh` | your overrides, sourced last |
| `~/.zshrc.local` | extra escape hatch |
| `~/.config/zsh/secrets.zsh` | secrets, mode 600 |

To add plugins without editing managed files:

```sh
echo 'zsh-users/zsh-history-substring-search' > ~/.config/zsh/plugins.local.txt
echo 'antidote load ~/.config/zsh/plugins.local.txt' >> ~/.config/zsh/local.zsh
```

To change the managed configuration itself, edit the chezmoi source
(`chezmoi cd`) and commit.

## Secrets

Prefer a credential helper (`git credential`, `gh auth`, `glab auth`) over
exporting tokens. If you must export a value:

```sh
chmod 600 ~/.config/zsh/secrets.zsh
echo 'export GITEA_TOKEN="..."' >> ~/.config/zsh/secrets.zsh
```

## Upgrade and pin

`chezmoi update` fetches and applies the latest source. To pin or roll back:

```sh
git -C "$(chezmoi source-path)" fetch --tags
git -C "$(chezmoi source-path)" checkout v3.0.0
chezmoi apply
```

## Uninstall

```sh
chezmoi purge     # removes chezmoi's config/state/source; installed files remain
```

Delete the installed files you no longer want yourself.

## Migrating from v2

See [docs/migrating-from-v2.md](docs/migrating-from-v2.md).

## Project layout

```
dot_zshenv, dot_zshrc          managed shell entrypoints
dot_config/zsh/                plugin lists and conf.d fragments
dot_config/starship.toml       prompt
run_once_before_00-backup.sh   first-run backup of existing shell files
install.sh                     prerequisite check + chezmoi init --apply
ci/                            hygiene checks and the end-to-end install test
```

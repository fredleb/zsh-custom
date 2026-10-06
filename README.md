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

### Tool homes outside the XDG directories

The framework does not set the XDG base-directory variables
(`XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, `XDG_DATA_HOME`); it only uses them when
you set them. Some tools keep data outside those directories but derive their
home from an XDG variable when it is present — for example Debian's nvm init,
which points `NVM_DIR` at `$XDG_CONFIG_HOME/nvm`. If such a tool stops finding
its data, pin its home in `local.zsh` before the tool is sourced:

```sh
export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/init-nvm.sh
```

## Secrets

Prefer a credential helper (`git credential`, `gh auth`, `glab auth`) over
exporting tokens. If you must export a value:

```sh
chmod 600 ~/.config/zsh/secrets.zsh
echo 'export GITEA_TOKEN="..."' >> ~/.config/zsh/secrets.zsh
```

## Shell conveniences

The default configuration provides these out of the box. Most come from
upstream oh-my-zsh library files loaded through antidote (`lib/directories.zsh`
and `lib/history.zsh`); prefix history search and the terminal navigation keys
use zsh's own built-in line-editor widgets. All track upstream rather than being
hand-maintained here.

| Convenience | Source |
|---|---|
| `l`, `ll`, `la`, `lsa` — list directory contents | `lib/directories.zsh` |
| `..` — change to the parent directory | `lib/directories.zsh` (via `auto_cd`) |
| `md`, `rd`, `-`, `1`–`9`, `d`, `...` | `lib/directories.zsh` |
| Up/Down recall history, shared across shells | `lib/history.zsh` |
| With text typed, Up/Down walk the history entries beginning with it, skipping repeats | zsh built-in widgets |
| Delete, Home, End, Insert, PageUp, PageDown behave in any editing mode | zsh built-in widgets |
| Shift+Delete, Ctrl+Delete, Alt+Delete delete text in any editing mode | zsh built-in widgets |
| Ctrl-R searches history; emacs editing keys work whatever `$EDITOR` is | zsh built-in widgets |
| A command line starting with a space is not recorded | `lib/history.zsh` |

To override any of these, edit `~/.config/zsh/local.zsh` (sourced last), for
example:

```sh
# Use different listing flags
alias l='ls -lFh'
# Do not change directory when a bare directory name is typed
unsetopt auto_cd
# Record space-prefixed commands after all
unsetopt hist_ignore_space
# Use vi key bindings in the shell instead of the default emacs bindings
bindkey -v
```

## Release policy

Every merge to the main branch is a release. The pull request carries the
version bump and a `CHANGELOG.md` entry, using semantic versioning: MAJOR for a
breaking change, MINOR for a new or changed user-visible capability, PATCH for a
fix, documentation, or internal change. CI blocks a merge to main whose version
is unchanged, and a workflow tags the merged version.

To enforce this in the repository settings, require the `version` check to pass
before merging to `main` (Settings → Branches → branch protection). Merges that
bypass CI are still tagged by the release workflow on push.

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

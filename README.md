# zsh-custom

A small, safe, upgradeable zsh configuration for teams. It manages plugins with
[antidote](https://getantidote.github.io) and the prompt with
[Starship](https://starship.rs), and it is designed so that **upgrading never
overwrites your configuration**.

## Design in one picture

```
~/.zshrc  (yours; contains a version-invariant managed block)
   └─ source <repo>/init.zsh          framework (read-only to you)
        └─ source $ZSHRC_CUSTOM/...   your layer (never touched by updates)
```

- The managed block never changes between versions → upgrades are a `git pull`.
- Your customization lives in `$ZSHRC_CUSTOM` (default `~/.config/zsh-custom`).

## Requirements

- zsh >= 5.4
- **[antidote](https://getantidote.github.io)** installed system-wide
- **[Starship](https://starship.rs)** installed system-wide

zsh-custom **does not install system packages and never runs `sudo`**. If a
dependency is missing, the installer prints the command you should run and exits.

| Platform | antidote | Starship |
|---|---|---|
| Arch | `yay -S zsh-antidote` | `sudo pacman -S starship` |
| Debian/Ubuntu | `sudo apt-get install zsh-antidote` | `sudo apt-get install starship` |
| macOS | `brew install zsh-antidote` (or clone antidote) | `brew install starship` |

## Install

```sh
git clone https://github.com/fredleb/zsh-custom.git ~/.zsh-custom
~/.zsh-custom/install.sh -y
exec zsh
```

The installer:

1. verifies system dependencies (and stops with instructions if any is missing),
2. backs up your existing `~/.zshrc` before changing anything,
3. migrates a legacy antigen configuration non-destructively,
4. injects the managed block,
5. seeds `$ZSHRC_CUSTOM` from templates (only files that do not exist yet).

It is safe to re-run.

## Upgrade

```sh
zsh-custom update                 # latest release tag
zsh-custom update --version v2.0.1
exec zsh
```

Your `~/.zshrc` and your `$ZSHRC_CUSTOM` layer are not modified by an update.
Roll back the same way: `zsh-custom update --version v2.0.0`.

## Customize

The default prompt is **font-free** — no Nerd Font is required. If you want
icons, you can enable them in your own `theme.toml`.

Everything lives in `$ZSHRC_CUSTOM` (default `~/.config/zsh-custom`):

| File | Purpose |
|---|---|
| `plugins.txt` | extra antidote plugins (loaded after defaults, before syntax highlighting) |
| `conf.d/*.zsh` | configuration fragments, sourced in lexical order (yours override defaults) |
| `theme.toml` | Starship prompt override (copy `theme.toml.example` to start) |
| `secrets.zsh` | secrets, mode 600 |
| `local.zsh` | escape hatch, sourced last |

Load order: framework defaults → your `conf.d/*.zsh` → your `plugins.txt` →
syntax highlighting → your `local.zsh`.

## Secrets

Do not put secrets in files that get backed up. Prefer a **credential helper**
(`git credential`, `gh auth`, `glab auth`) over exported tokens.

If you must export a value, put it in `$ZSHRC_CUSTOM/secrets.zsh`:

```sh
chmod 600 ~/.config/zsh-custom/secrets.zsh
echo 'export GITEA_TOKEN="..."' >> ~/.config/zsh-custom/secrets.zsh
```

The framework warns if this file is group/world readable. CI scans the public
repo for committed secrets.

## Uninstall

```sh
zsh-custom uninstall     # removes only the managed block
```

Your `$ZSHRC_CUSTOM` layer is left in place; delete it yourself if you want.

## Diagnostics

```sh
zsh-custom doctor
```

## Project layout

```
init.zsh               stable entrypoint
conf.d/                framework defaults (antidote, prompt, secrets)
zsh_plugins.txt        default plugins
zsh_plugins.last.txt   syntax highlighting (always last)
starship.toml          default prompt
templates/user/        seeded into $ZSHRC_CUSTOM
bin/zsh-custom         CLI
lib/                   installer/CLI internals
ci/                    hygiene checks used by CI
```

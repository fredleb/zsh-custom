# zsh-custom

A small, safe, upgradeable zsh configuration for teams. It manages plugins with
[antidote](https://getantidote.github.io) and the prompt with
[Starship](https://starship.rs), and it is designed so that **upgrading never
overwrites your configuration**.

## Design in one picture

```
~/.zshrc  (yours; contains a version-invariant managed block)
   └─ source <clone>/init.zsh          framework (read-only to you)
        └─ source $ZSHRC_CUSTOM/...    your layer (never touched by updates)
```

- The managed block never changes between versions, so upgrading never rewrites
  `~/.zshrc`.
- Your customization lives in `$ZSHRC_CUSTOM` (default `~/.config/zsh-custom`).

## The `zsh-custom` command

The CLI lives in the clone at `<clone>/bin/zsh-custom` (default
`~/.zsh-custom/bin/zsh-custom`). After you restart your shell it is **also on
your `PATH`** as plain `zsh-custom`.

The examples below use the full path, so they work even before you restart your
shell. Once you have run `exec zsh`, you can drop the prefix and just run
`zsh-custom …`.

## Requirements

- zsh >= 5.4
- **[antidote](https://getantidote.github.io)** installed system-wide
- **[Starship](https://starship.rs)** installed system-wide

zsh-custom **does not install system packages and never runs `sudo`**. If a
dependency is missing, the installer stops and prints the command you should run.

| Platform | antidote | Starship |
|---|---|---|
| Arch | `yay -S zsh-antidote` | `sudo pacman -S starship` |
| Debian/Ubuntu | `sudo apt-get install zsh-antidote` | `sudo apt-get install starship` |
| macOS | `brew install zsh-antidote` (or clone antidote) | `brew install starship` |

## Install (first time)

```sh
git clone https://github.com/fredleb/zsh-custom.git ~/.zsh-custom
~/.zsh-custom/install.sh -y
exec zsh
```

> If `~/.zsh-custom` already exists, skip the `git clone` step — see
> [Upgrade](#upgrade) instead.

The installer:

1. verifies system dependencies (and stops with instructions if any is missing),
2. backs up your existing `~/.zshrc` before changing anything,
3. migrates a legacy antigen configuration non-destructively,
4. injects the managed block,
5. seeds `$ZSHRC_CUSTOM` from templates (only files that do not exist yet).

It is safe to re-run. Restart your shell afterwards (`exec zsh`) so the
framework and the `zsh-custom` command load.

## Upgrade

Upgrading fetches the release tags, checks out the newest one, rebuilds the
plugin cache, and validates before activating. It does **not** touch `~/.zshrc`
or `$ZSHRC_CUSTOM`.

```sh
~/.zsh-custom/bin/zsh-custom update
exec zsh
```

`update` fetches the release tags itself, so an old clone is fine — no separate
`git pull` is needed. (To track unreleased `master` instead, run
`git -C ~/.zsh-custom checkout master && git -C ~/.zsh-custom pull`.)

### Upgrading from the pre-v2 layout

If your clone predates v2 it has no `bin/zsh-custom` and no `init.zsh`. Bring
the clone up to date, then run the new installer once:

```sh
git -C ~/.zsh-custom fetch origin
git -C ~/.zsh-custom checkout master
git -C ~/.zsh-custom pull --ff-only
~/.zsh-custom/install.sh -y      # migrates your legacy ~/.zshrc
exec zsh
```

After that, use `~/.zsh-custom/bin/zsh-custom update` (or `zsh-custom update`)
for future upgrades.

### Pin or roll back to a specific version

Use a version that exists — list them first:

```sh
git -C ~/.zsh-custom tag -l 'v*' --sort=-v:refname     # e.g. v2.0.0
~/.zsh-custom/bin/zsh-custom update --version v2.0.0
```

`update` checks out the release tag, so the clone ends up on a detached HEAD —
that is normal. Run `update` again (with or without `--version`) to move to a
different release.

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
~/.zsh-custom/bin/zsh-custom uninstall     # removes only the managed block
```

Your `$ZSHRC_CUSTOM` layer is left in place; delete it yourself if you want.

## Diagnostics

```sh
~/.zsh-custom/bin/zsh-custom doctor
```

## Troubleshooting

- **`zsh-custom: command not found`** — the command is on your `PATH` only after
  the framework loads. Run `exec zsh`, or use the full path
  `~/.zsh-custom/bin/zsh-custom`.
- **Installer stops with "antidote/starship is not installed system-wide"** —
  install the package it prints (Requirements above), then re-run
  `~/.zsh-custom/install.sh`.
- **`update --version vX` fails** — that version does not exist. List real
  releases with `git -C ~/.zsh-custom tag -l 'v*' --sort=-v:refname`.

## Project layout

```
init.zsh               stable entrypoint
conf.d/                framework defaults (antidote, prompt, secrets)
zsh_plugins.txt        default plugins (pre-compinit)
zsh_plugins.git.txt    git plugin/lib (post-compinit)
zsh_plugins.last.txt   syntax highlighting (always last)
starship.toml          default prompt
templates/user/        seeded into $ZSHRC_CUSTOM
bin/zsh-custom         CLI
lib/                   installer/CLI internals
ci/                    hygiene checks used by CI
```

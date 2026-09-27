# Migrating from zsh-custom v2 (managed block)

v2 injected a managed block into `~/.zshrc`. v3 replaces that with chezmoi.

## 1. Install chezmoi and apply this repo

```sh
# macOS / Linux with Homebrew:
brew install chezmoi
# Debian/Ubuntu (if packaged):
#   sudo apt-get install chezmoi

git clone https://github.com/fredleb/zsh-custom.git ~/.zsh-custom-v3
~/.zsh-custom-v3/install.sh
```

On first apply, your existing shell files (`~/.zshrc`, `~/.zshenv`, etc.) are
copied to `*.pre-chezmoi` before the managed files are written.

## 2. Move personal configuration into the untracked layer

v2 kept personal settings in `~/.config/zsh-custom/`. v3 does not create or
manage that directory; move its contents:

- `~/.config/zsh-custom/secrets.zsh` → `~/.config/zsh/secrets.zsh`, then
  `chmod 600 ~/.config/zsh/secrets.zsh`
- other personal lines → `~/.config/zsh/local.zsh`
- extra plugins → a personal list, e.g. `~/.config/zsh/plugins.local.txt`,
  loaded from `local.zsh` with `antidote load ~/.config/zsh/plugins.local.txt`

`~/.config/zsh/local.zsh` and `~/.zshrc.local` are sourced last and are never
touched by updates.

## 3. Remove the old clone

```sh
rm -rf ~/.zsh-custom
```

The v2 managed block lived in `~/.zshrc`, which chezmoi now owns, so it is gone.

## 4. Confirm

```sh
chezmoi diff      # should show no drift
zsh -i -c exit    # should print nothing
```

## Tools whose data lives outside `~/.config`

v3 does not set `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, or `XDG_DATA_HOME`. If
your environment already sets one of them, a tool that derives its home from it
can be redirected. Debian's nvm init sets `NVM_DIR="$XDG_CONFIG_HOME/nvm"`, so
nvm can stop finding versions installed under `~/.nvm`. Pin it in
`~/.config/zsh/local.zsh` before nvm is sourced:

```sh
export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/init-nvm.sh
```

## Rollback to v2

Check out the `v2.0.1` tag in the old clone and re-run its `install.sh` (the
managed block is version-invariant). Restore a `*.pre-chezmoi` file over
`~/.zshrc` first if you want your previous hand-edited file back.

# Stop Imposing XDG Defaults

## Why

`dot_zshenv` force-exports `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, and
`XDG_DATA_HOME` to their default values. Setting these to their defaults is not
a no-op: a tool that treats them as an **override** rather than falling back is
silently redirected. Debian's `init-nvm.sh` sets `NVM_DIR="$XDG_CONFIG_HOME/nvm"`
whenever `XDG_CONFIG_HOME` is set, so after migrating to v3, nvm looked in the
empty `~/.config/nvm` instead of `~/.nvm`, its installed Node version vanished
from `PATH`, and `node` silently fell back to `/usr/bin/node`. The framework
should not impose XDG defaults on the user's environment.

## What Changes

- `dot_zshenv` stops setting `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, and
  `XDG_DATA_HOME` when they are unset. The framework continues to resolve its
  own managed paths from those variables, falling back to the standard
  locations, and it continues to honor values the user has already set.
- Documentation explains the interaction for users whose environment already
  sets `XDG_CONFIG_HOME`, with the remedy of pinning `NVM_DIR` before sourcing
  nvm in the user customization layer.
- A `shell-bootstrap` requirement codifies that the framework does not impose
  XDG base-directory defaults.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `shell-bootstrap`: add a requirement that the framework does not set XDG
  base-directory variables to defaults and honors user-supplied values.

## Impact

- `dot_zshenv`; user-facing documentation; `CHANGELOG.md`; CI checks; and
  `openspec/specs/shell-bootstrap/spec.md` (on archive).
- No new dependencies. The framework's own configuration, cache, and data paths
  are unchanged; tools that key off `XDG_CONFIG_HOME` (such as nvm) work again.
- Behavior change: the three XDG variables are no longer set to defaults by the
  shell, so tools fall back to their own non-XDG defaults where applicable.

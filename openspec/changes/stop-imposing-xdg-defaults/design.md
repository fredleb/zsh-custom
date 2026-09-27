# Design: Stop Imposing XDG Defaults

## Context

See `proposal.md` for motivation.

- `dot_zshenv` currently exports `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, and
  `XDG_DATA_HOME` using `${VAR:-default}`, so it materializes defaults that were
  otherwise unset.
- Every internal consumer already uses the same fallback: `dot_zshrc` derives
  `ZSH_CONFIG` and `ZSH_CACHE` from `${XDG_*:-…}`, and `conf.d` reads those. No
  framework code requires the variables to be *set*.
- Debian's `/usr/share/nvm/init-nvm.sh` sets `NVM_DIR="$XDG_CONFIG_HOME/nvm"`
  when `XDG_CONFIG_HOME` is set (upstream nvm does not; it defaults to
  `~/.nvm`). This is what stranded nvm's Node version under `~/.nvm`.
- No spec mentions XDG today, so nothing prevents this from being reintroduced.

## Goals / Non-Goals

**Goals:**

- The shell environment no longer gains XDG variables the user did not set.
- The framework's own paths are unaffected, and user-set values keep working.
- The rule is codified so a future "be more XDG-correct" change cannot silently
  reintroduce the redirect.

**Non-Goals:**

- Relocating any tool's data, or setting any other tool-specific variable.
- Changing where chezmoi installs managed files.
- Cleaning up `~/.config/nvm` left behind by the breakage (user action).

## Decisions

**D1 — Stop setting defaults for all three variables, not just
`XDG_CONFIG_HOME`.** "B-wide" keeps one coherent rule ("the shell does not
impose XDG defaults"), matches `dot_zshenv`'s own stated contract ("fast and
side-effect free"), and closes the same footgun class for tools that key off
`XDG_CACHE_HOME`/`XDG_DATA_HOME`. Alternatives: remove only `XDG_CONFIG_HOME`
(smaller diff, leaves an inconsistent rule) and keep the exports but document
the hazard (does not fix it).

**D2 — Do not unset or normalize existing values.** The change only removes the
defaulting; a user-supplied value is passed through untouched, preserving the
current honoring behavior.

**D3 — Document the residual case.** Users whose environment already sets
`XDG_CONFIG_HOME` (for example the current session, started under the old
config) still get `NVM_DIR` redirected by Debian's wrapper. Documentation
carries the one-line remedy:

```sh
# in ~/.config/zsh/local.zsh, before sourcing nvm
export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/init-nvm.sh
```

**D4 — Codify the rule in `shell-bootstrap`.** A requirement with scenarios
("defaults are not imposed", "user values are honored", "a tool's non-XDG home
is preserved") makes the behavior testable and regression-proof.

**D5 — Classify as MINOR, without a deprecation window.** The distribution spec
calls a changed user-visible capability MINOR and requires a deprecation window
before removing user-facing behavior. Removing the imposed XDG defaults changes
observable environment behavior, so it is a MINOR change; no deprecation window
is needed because the exports were never documented behavior and the effective
paths for XDG-compliant tools are unchanged. Recorded here so the judgment is
explicit rather than accidental.

## Risks / Trade-offs

- **A user script depended on `$XDG_CONFIG_HOME` being set by the shell** →
  effective migration: the value would only be missing if it was never set,
  which is the pre-v3 status quo; the README documents the change.
- **Some tool distinguishes "unset" from "set to default"** → that is precisely
  the intended restoration; tools should fall back themselves.
- **The fix does not help an already-broken session** → D3 documentation, and a
  fresh shell after the change is sufficient.
- **CI sandboxes set their own XDG values** → unaffected; add an assertion that
  a fresh shell leaves unset XDG variables unset.

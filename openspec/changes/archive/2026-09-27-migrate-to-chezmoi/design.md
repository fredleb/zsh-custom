## Context

See `proposal.md` — Why. Requirement changes are in `specs/`. The constraints that shape this design:

- The repo is **public** and already cloned by colleagues; anything merged is effectively a published interface, so the migration needs a documented path and a rollback.
- Users install on **many machines** across **Linux and macOS**, and v2 users have a managed block in a hand-edited `~/.zshrc` that must not be lost.
- The v2 `design.md` already decided the project would **not** become a dotfiles manager ("no templating engine, no multi-machine state database"). This change reverses that decision deliberately, because the custom lifecycle that replaced it is the largest remaining maintenance surface.
- The `distribution` capability requires dependencies to come from **package managers or immutable/ pinned sources**, not mutable download endpoints — so the "just `curl | sh` chezmoi" bootstrap is out of bounds.
- `shell-bootstrap` and `distribution` require **no privilege escalation** by the framework.

## Goals / Non-Goals

**Goals:**
- Delete the bespoke distribution layer (managed block, custom installer/CLI, user-layer seeding, antigen migration) without losing any user-visible capability.
- Keep the two decisions v2 got right: **antidote** for plugins and **Starship** for the prompt.
- Make Linux and macOS first-class, verified by CI.
- Keep the user's personal configuration and secrets untouchable by updates.

**Non-Goals:**
- Adopting chezmoi **templating** for per-machine differences now. Platform differences are resolved at runtime; templating is a later, additive step if per-person identity (e.g. git config) is ever managed.
- Managing non-zsh dotfiles (git, vim, etc.). Only the zsh configuration and the Starship config are in scope.
- Installing packages, including chezmoi. The framework detects and instructs.
- Changing plugin, prompt, or completion behavior.

## Decisions

### Decision: chezmoi is the distribution layer; the repo becomes its source directory
Use chezmoi for install/update/diff/status/doctor/uninstall. The repo adopts chezmoi's source-state naming (`dot_zshrc`, `dot_config/...`, `.chezmoiignore`, `run_once_before_*`).
- *Alternatives*: keep the v2 custom lifecycle (rejected — this is the wheel being removed); **yadm** (git-native, but no templating/`doctor`/drift model and weaker cross-platform story); **GNU Stow** (symlinks only; no secrets, no drift); **dotbot** (manifest + symlinks; no diagnostics); **zimfw** (replaces the in-shell layer too, but is per-user and does not solve team distribution — would still need chezmoi).

### Decision: Keep antidote and Starship; change only the distribution layer
Antidote stays for staged plugin loading; Starship stays for the prompt at its default config path (`~/.config/starship.toml`), removing the `STARSHIP_CONFIG` export.
- *Alternatives*: switch the in-shell layer to zimfw/oh-my-zsh (rejected — no benefit for this migration and it re-opens behavior decisions v2 already settled); replace antidote with `zsh_unplugged` (rejected — re-implements what antidote does).

### Decision: chezmoi is a system prerequisite, not a downloaded binary
`install.sh` verifies that `chezmoi`, `antidote`, and `starship` are present and prints per-platform install commands when any is missing; it never installs them. This matches the existing "system dependencies, never install, never escalate" philosophy and the `distribution` requirement.
- *Alternatives*: `curl -fsLS get.chezmoi.io | sh` (rejected — mutable bootstrap URL, and the framework would be installing a dependency); download a pinned chezmoi release asset (rejected — an arch/OS matrix to maintain for no user benefit when Homebrew and distro packages exist).

### Decision: Untracked user layer instead of a seeded, managed layer
Personal configuration lives in files the framework never manages: `~/.config/zsh/local.zsh`, `~/.config/zsh/secrets.zsh`, `~/.zshrc.local`. The managed `~/.zshrc` sources them if present. This replaces `$ZSHRC_CUSTOM` and its template seeding.
- *Alternatives*: keep `$ZSHRC_CUSTOM` and have the managed rc source it (viable, but keeps a bespoke concept that chezmoi already expresses as "untracked files"); make users edit managed files directly (rejected — guarantees drift conflicts).

### Decision: Runtime platform detection, no templates yet
Linux/macOS differences are handled with `$OSTYPE` and `brew --prefix` at shell startup. No `.tmpl` files are introduced in this change.
- *Alternatives*: chezmoi Go templates for platform paths (rejected for now — more moving parts, requires re-apply to change, and the runtime detection already works on both platforms; templates remain available for per-person data later).

### Decision: First-run backup via a chezmoi run-once script
`run_once_before_00-backup.sh` copies existing `~/.zshrc`/`.zshenv`/`.zprofile`/`.zlogin` to `*.pre-chezmoi` once, before the managed files are written.
- *Alternatives*: rely on chezmoi's conflict prompt (rejected — depends on interactive mode and is not a durable backup); no backup (rejected — the public repo must not risk user content).

### Decision: Version by git tags on the source
Drop `VERSION`; the installed version is the checked-out tag of the source checkout, and pinning/rollback is a checkout plus re-apply.
- *Alternatives*: keep `VERSION` (rejected — a second source of truth beside git tags); a chezmoi `data` version (rejected — not needed for reporting).

### Decision: CI verifies both platforms end to end
Replace the v2 install job with a matrix that runs `ci/test-install.sh` on `ubuntu-latest` and `macos-latest`, keeping the lint and hygiene jobs.
- *Alternatives*: keep macOS as syntax/headless only (rejected — the migration changes the install path on both platforms; the `shell-bootstrap` requirement explicitly names macOS).

## Risks / Trade-offs

- **chezmoi overwrites `~/.zshrc` on first apply** → the run-once backup preserves the old file; docs tell users to run `chezmoi diff` first; `chezmoi` also surfaces conflicts.
- **chezmoi may be unavailable in some distros' repos** → document Homebrew-on-Linux as a fallback; the framework instructs rather than downloads, so it stays within the immutable-source rule.
- **Behavioral change: users no longer "keep their own `~/.zshrc`"** → the migration guide and README make the untracked layer (`local.zsh`, `.zshrc.local`) the obvious place for personal settings.
- **Public breaking change to v2 users** → semver major, changelog with required actions, and a documented rollback (check out the v2 tag and restore `*.pre-chezmoi` / the old installer).
- **Antidote writing generated files into the managed config dir would show as unmanaged noise** → bundles are built into `$XDG_CACHE_HOME/zsh`, not into `~/.config/zsh`.
- **Generated secrets or local files accidentally committed** → `.chezmoiignore` plus `.gitignore` patterns, and the existing secret scan remains a required CI check.
- **Task ordering hazard: deleting v2 files before porting their content** → tasks port content first and delete in a later, explicitly guarded step.

## Migration Plan

1. Land the new source layout on a branch, porting content from the v2 files before deleting them.
2. Add `install.sh`, `run_once_before_00-backup.sh`, and the CI/test changes.
3. Delete the v2 framework files and update `.gitignore` in one guarded commit.
4. Rewrite the README and add `docs/migrating-from-v2.md`.
5. Release `v3.0.0` with a changelog entry stating the breaking changes and the one-time steps.
6. **Rollback**: check out `v2.0.1`, re-run its `install.sh` (the managed block is version-invariant), and restore any `*.pre-chezmoi` file if the user wants their previous `~/.zshrc` back.

## Open Questions

- Whether to also publish a Homebrew formula or AUR package for the configuration later (would not change the specs or task breakdown).

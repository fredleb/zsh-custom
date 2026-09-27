## Context

See `proposal.md` — Why. The constraints that shape this design:

- The repo is **public** and already cloned by other people, so anything merged is effectively a published interface; breaking it strands users.
- Users install on **many machines** (Linux, likely macOS) and have **hand-edited `~/.zshrc`** from the antigen era. Their edits must not be lost.
- The current installer **copies a template over `~/.zshrc`**, which is the root cause of drift and loss. The fix must remove that class of failure, not just patch it.
- The host referenced antigen at a path that no longer exists, so the current configuration is **broken on shell start**.
- The repository currently has no tests, no tags, and no changelog, so there is no mechanism to make changes safely.

## Goals / Non-Goals

**Goals:**
- Make upgrading equal to `git pull` (or equivalent), with zero risk to user content.
- Give users and sites a supported customization layer that outlives framework updates.
- Replace custom glue with maintained FOSS (antidote, Starship, zsh-users plugins).
- Provide a real secrets story and eliminate secrets from installer backups.
- Put the public repo on a footing where changes can be made safely: tags, changelog, CI, docs.

**Non-Goals:**
- Supporting shells other than zsh.
- Becoming a full dotfiles manager (no templating engine, no multi-machine state database).
- Per-project environment management (direnv) beyond exposing a documented hook.
- Managing non-zsh dotfiles.

## Decisions

### Decision: Antidote as the plugin manager
Use **antidote**. It is the maintained successor to antigen, has an official migrating-from-antigen guide, is packaged by distributions (`zsh-antidote`), and separates "declare plugins in a text file" from "load them", which makes the plugin set reviewable in a diff.
- *Alternatives*: stay on antigen (unmaintained, already broken); zinit/zap (more powerful, more complex, heavier config surface); full oh-my-zsh framework (slow, large, opinionated).

### Decision: Starship is the sole prompt, no legacy fallback
Use **Starship**, configured by TOML, as the single prompt. It is actively maintained, cross-shell, and its config file is the customization surface — which directly serves the "easily customizable" goal. The custom `themes/fidji.zsh-theme` SHALL be removed once parity is confirmed; no legacy theme fallback is offered. The target is **visual parity** with the current two-line Bureau-style prompt: `user@host`, abbreviated path, right-aligned time on the first line; `$`/`#` character with a failure indicator on the left and node version + git branch/status on the right of the second line.
- The default configuration SHALL remain **font-free** (plain Unicode symbols `⬡ ± ▴ ▾ ●`, no Nerd Font requirement), matching the current theme's portability.
- Two known deltas from the old theme: the "member of sudo group" character color is not a built-in Starship behavior (replicate with a small custom module or accept a simplified character color), and exact spacing/colors are matched by tuning, not guaranteed pixel-identical. Parity SHALL be confirmed side-by-side before the theme file is deleted.
- *Alternatives*: powerlevel10k (fast and familiar, but on life support as of 2025, so it fails the "well-maintained" requirement as a default); `pure`/`spaceship` (maintained, but more zsh-embedded and less trivially configurable); keeping the custom theme (more code to maintain, the very thing being removed); offering the legacy theme as an opt-in fallback (rejected — it would keep the old coupling alive in the user layer).

### Decision: Stable managed block instead of copying a template
`install.sh` writes a marker-delimited block into `~/.zshrc` that only sources the framework entrypoint. Because the block content is version-invariant, upgrades never rewrite `~/.zshrc`. All framework evolution happens behind the entrypoint.
- *Alternatives*: keep copying the template (destroys user config — rejected); symlink `~/.zshrc` to the repo (couples machine state into the repo and makes the repo the editable file — rejected); rewrite the whole file each time with a generated header (still loses ad-hoc user lines — rejected).

### Decision: User customization layer with deterministic ordering
Provide `$ZSHRC_CUSTOM` (default `~/.config/zsh-custom`), created from a template once and never overwritten. Load order: framework defaults → user `conf.d/*.zsh` in lexical order → user `plugins.txt` → `local.zsh` last. Later wins. This mirrors the proven `$ZSH_CUSTOM` pattern in oh-my-zsh but with explicit ordering.
- *Alternatives*: a single `~/.zshrc.local` file (simpler, but one file becomes the new monolith); requiring users to fork (bad for colleagues and strangers).

### Decision: One-command lifecycle behind a small CLI
Provide a `zsh-custom` command surface — `install`, `update`, `doctor`, `version`, `uninstall` — so the common operations are one command each. `update` fetches released tags, checks out the newest (or a requested) version, refreshes caches, validates, and reports; it never edits `~/.zshrc` or the user layer. Users may pin a version (`update --version vX`) or roll back by the same mechanism.
- *Alternatives*: document raw `git pull` (works, but error-prone and unfriendly for colleagues); a package-manager package per platform (more maintenance than this repo warrants now).

### Decision: Dependencies are system-installed, not per-user
Antidote and Starship SHALL be provided by the system package manager; the framework SHALL NOT vendor them into a per-user directory. Concretely, on Arch antidote is `zsh-antidote`, installed at `/usr/share/zsh-antidote/` and activated with `source /usr/share/zsh-antidote/antidote.zsh` — the package does **not** modify `fpath` itself, so the framework must source it explicitly and resolve the path across distros. Starship is `extra/starship` (or the distro equivalent). Missing dependencies SHALL produce platform-specific, actionable install instructions rather than a silent failure. The framework SHALL NOT invoke `sudo`, `su`, `doas`, or otherwise escalate privileges, and SHALL NOT install system packages itself — it detects and instructs, and the user performs the privileged step. Antidote's own plugin bundle cache remains per-user; that is the tool's design and is not what "system-installed" refers to.
- *Alternatives*: per-user `git clone` into `~/.antidote` (rejected — the dependency model is now system-wide, avoiding N copies and version drift across users); `curl | bash` from mutable URLs (rejected — supply-chain risk).
- *Known risk*: on distributions/OSes without a package (or without package-manager access), this model gives no automatic path. The framework stops with platform-specific instructions and **does not** vendor a per-user fallback copy.
### Decision: Drop full oh-my-zsh, load only needed plugins
Load the `git` library file and `git` plugin through antidote's oh-my-zsh path rather than the whole framework. The custom theme only needed oh-my-zsh for colors (available from zsh's built-in `colors`) and its git/nvm prompt functions (covered by Starship).
- *Alternatives*: keep loading full oh-my-zsh (slow startup, and it is the source of the old coupling); drop oh-my-zsh entirely and lose the git aliases some users rely on (a compatibility risk for existing users).

### Decision: Secrets as a user-layer file, helper-first guidance
Source `$ZSHRC_CUSTOM/secrets.zsh` (0600, gitignored) when present, warn on loose permissions, and document credential helpers as the preferred path for tokens. Add secret scanning to CI. For the Gitea token specifically, prefer a git credential helper or `glab`/`gh` auth over an exported variable.
- *Alternatives*: `pass`/`gopass`, `age`+`sops`, 1Password/`op`, OS keyring — all better for teams, but add a dependency; the file layer is manager-agnostic and can wrap any of them later.

### Decision: Upgrade via checkout, released with tags and a changelog
Users upgrade by pulling a released tag; the entrypoint exposes its version. Deprecations precede removals by at least one release. CI runs lint, zsh syntax check, secret scan, headless load, and idempotency tests.
- *Alternatives*: chezmoi/stow/home-manager (powerful but a much larger commitment than this repo warrants); no versioning (unsafe for a public tool).

### Decision: Keep project tooling in the public repo
The `.opencode/` and `openspec/` directories stay. They document how the change was planned and are harmless to users; removing them would hide the reasoning. (Revisit if they ever confuse users.)

## Risks / Trade-offs

- **Starship needs a Nerd Font for icons** → default config degrades to plain glyphs; document the font, and make icon usage a user-layer toggle.
- **Users may edit inside the managed block** → installer detects drift between markers and rewrites the block with a warning rather than failing.
- **Plugin fetch failures on locked-down networks** (many corporate machines) → fail-soft loading, cached resolution, and documented package-manager/AUR install for antidote.
- **Migration may misclassify hand-written lines** → always back up first; abort rather than guess when a line cannot be classified; report exactly what moved where.
- **Pre-existing `.zshrc.*` backups already contain the exported token** → migration documents the path and the need to review/remove; the maintainer must rotate the token.
- **Public repo: a breaking change reaches strangers** → semver, changelog, deprecation window, and cheap rollback by checking out a prior tag.
- **macOS/Linux divergence** → CI matrix across both; platform detection in the installer.
- **System dependency unavailable** (distribution without a package, macOS, or no package-manager access) → the system-installed model has no automatic path; the installer prints exact per-platform install commands, exits non-zero, and does **not** install a per-user copy. The README documents provisioning per platform.
- **Startup performance regressions** → dropping oh-my-zsh and lazy-loading nvm should improve startup; add a startup-time check as a soft CI signal.

## Migration Plan

1. **Interim unbreak** (ships first, small): stop the shell errors for current users by restoring a working plugin path without changing the interface. This prevents anyone being stranded during the redesign.
2. **Land v2 on a branch**, with the new entrypoint, plugin file, Starship config, user-layer templates, rewritten installer, and CI.
3. **Migration path in installer**: back up `~/.zshrc`, detect the legacy antigen block, relocate unknown user lines into `$ZSHRC_CUSTOM/conf.d/00-migrated.zsh`, inject the stable managed block, and print a summary.
4. **Release v2.0.0** with a CHANGELOG entry that states the breaking changes and the one-time migration step.
5. **Rollback**: users can check out the previous tag; because the managed block is version-invariant, their `~/.zshrc` does not need to change to roll back.

## Open Questions

- The exact default Starship look (which modules, icon set, truncation) — finalize from the current theme's screenshots during implementation.
- Whether to also ship an opt-in powerlevel10k configuration for users who prefer it.
- Whether package-manager distribution (AUR/Homebrew) is worth the maintenance versus a documented `git clone`.

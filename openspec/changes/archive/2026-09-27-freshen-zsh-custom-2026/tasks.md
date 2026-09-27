## 1. Interim unbreak

- [x] 1.1 Skipped by decision: v2 supersedes the legacy antigen setup and the public repo has no active consumers, so no interim patch is published.
- [x] 1.2 Skipped by decision: no interim `v1.0.1` release; the v2.0.0 changelog documents the one-time migration instead.

## 2. Repository scaffolding and CI

- [x] 2.1 Add `.gitignore` covering user-layer secrets and local files; verify `git status` does not list a created `secrets.zsh` file.
- [x] 2.2 Add CI workflow running shellcheck, `zsh -n` over all zsh files, and secret scanning; verify the workflow fails a deliberately broken fixture (syntax error and a fake secret).
- [x] 2.3 Add CI job that performs a clean headless install and asserts a shell starts without errors; verify the job passes on Linux.
- [x] 2.4 Add CI job that runs the installer twice and asserts `~/.zshrc` is unchanged after the second run; verify the job passes.
- [x] 2.5 Add a macOS CI job (or matrix entry) for syntax and headless load; verify it passes. (Completed in the v3 chezmoi migration: the end-to-end install test now runs on both ubuntu-latest and macos-latest.)
- [x] 2.6 Add a CI check that fails when a privilege-escalation command (`sudo`, `su`, `doas`) appears in any script; verify it fails on a fixture containing `sudo` and passes otherwise.

## 3. Framework entrypoint and installer

- [x] 3.1 Create `init.zsh` as the stable entrypoint that sets the framework version and sources framework `conf.d` in order; verify `zsh -n init.zsh` passes and a shell sourcing it reports the version.
- [x] 3.2 Rewrite the installer to inject a marker-delimited managed block whose body is version-invariant; verify the block content is identical after installing two different versions.
- [x] 3.3 Make install idempotent and add an update path; verify running install twice leaves `~/.zshrc` unchanged and exits 0.
- [x] 3.4 Add uninstall that removes only the managed block; verify user lines outside the block remain.
- [x] 3.5 Add platform/prerequisite detection that verifies the **system-installed** antidote (resolving candidate paths such as `/usr/share/zsh-antidote/antidote.zsh`) and prompt, prints platform-specific install instructions when missing, and never executes them; verify it exits non-zero with a clear message when a dependency is absent and makes no `sudo`/`su`/`doas` call.
- [x] 3.6 Add pre-activation syntax validation with rollback to the prior state; verify a deliberately broken framework update leaves the shell starting from the previous state.
- [x] 3.7 Add the diagnostics command; verify it prints version, entrypoint, detected user-layer files, and problems.

## 4. Plugin management

- [x] 4.1 Add the default plugin list (completions, autosuggestions, syntax-highlighting last, git plugin) and load it via the **system-installed** antidote entrypoint; verify all behaviors are active in a fresh shell and that no per-user antidote copy is sourced.
- [x] 4.2 Remove all antigen references and the oh-my-zsh full-library load; verify no file references antigen or oh-my-zsh's library load.
- [x] 4.3 Add user plugin-list extension loading; verify a plugin added to the user list loads without editing framework files.
- [x] 4.4 Make plugin loading fail-soft; verify the shell starts and warns when a plugin path is unreachable.
- [x] 4.5 Add cached plugin resolution plus a refresh command; verify the second shell start does not re-resolve and refresh picks up a change.
- [x] 4.6 Restore the interactive completion menu (selectable list, arrow-key navigation, highlighting) that the previous oh-my-zsh configuration provided; verify the option, style, and module state matches oh-my-zsh's `lib/completion.zsh`.

## 5. Prompt

- [x] 5.1 Add the Starship configuration reproducing the current context (user/host, abbreviated path, git branch + ahead/behind + staged/unstaged/untracked, exit status, time); verify each appears in a test repository.
- [x] 5.2 Configure the Node/runtime context; verify the active Node version appears when nvm has a version active.
- [x] 5.3 Configure a readable no-Nerd-Font fallback and document the font requirement; verify the prompt renders readably with icons disabled.
- [x] 5.4 Remove the custom theme file and its references; verify no file references `themes/fidji.zsh-theme`.
- [x] 5.5 Allow prompt config override from the user layer; verify a user override wins over the default.
- [x] 5.6 Fix prompt color and spacing regressions: host, time, runtime, and git branch use the terminal default foreground; the host is blue only for remote sessions; the double space after the prompt character is removed.
- [x] 5.7 Colour the git status indicators by state (staged, modified, untracked, ahead/behind) as the previous theme did.

## 6. User customization layer

- [x] 6.1 Create the user-layer template (plugin list, `conf.d/`, prompt config, `secrets.zsh`, `local.zsh`) and have the installer copy it only when missing; verify edits survive a re-run of install.
- [x] 6.2 Implement deterministic load ordering (defaults → user conf.d lexical → user plugins → `local.zsh` last); verify a user setting overrides a framework default.

## 7. Secrets handling

- [x] 7.1 Source the user secrets file when present, with a permissions check and warning when too permissive; verify loading works, absence is silent, and a 0644 file warns.
- [x] 7.2 Ensure the installer backup happens before injection and document that pre-existing backups may contain secrets; verify an install over a config containing a token produces a backup and the injected block has no token.
- [x] 7.3 Document credential-helper preference and token migration, including the maintainer action to rotate the exposed Gitea token; verify docs contain the rotation step and helper guidance.

## 8. Migration of existing installs

- [x] 8.1 Implement legacy detection and relocation of unknown user lines into `$ZSHRC_CUSTOM/conf.d/00-migrated.zsh` with a summary; verify against a fixture of the current hand-edited `~/.zshrc`.
- [x] 8.2 Abort safely when a line cannot be classified; verify the installer leaves `~/.zshrc` untouched and explains the conflict on an ambiguous fixture.
- [x] 8.3 Verify the full migration on a clean container: install, confirm a shell starts with plugin and prompt active, and confirm user lines were preserved.

## 9. Release and documentation

- [x] 9.1 Rewrite the README (install, upgrade, customize, secrets, uninstall, supported platforms, version pinning); verify a fresh user can follow it end to end. (Was reopened for incorrect upgrade instructions; corrected and released in v2.0.1.)
- [x] 9.2 Add `CHANGELOG.md` and release `v2.0.0` with breaking-change and migration notes; verify the tag exists and the changelog documents the one-time migration.
- [x] 9.3 Verify rollback by checking out the previous tag and confirming the shell starts without changing `~/.zshrc`.

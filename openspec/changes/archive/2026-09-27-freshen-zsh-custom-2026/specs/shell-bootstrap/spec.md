## Purpose

Defines the install, update, and removal lifecycle of the zsh distribution, centered on a stable entrypoint that lets users upgrade without their shell configuration ever being overwritten.

## ADDED Requirements

### Requirement: Stable version-invariant managed block
The installer SHALL maintain a marker-delimited managed block inside the user's `~/.zshrc` whose content only sources the framework entrypoint. The content of that block SHALL remain constant across framework versions so that upgrading never requires rewriting the user's shell configuration.

#### Scenario: Upgrade does not touch the managed block
- **WHEN** a user with an existing install upgrades the framework
- **THEN** the managed block content is byte-for-byte unchanged
- **AND** all lines outside the managed block are preserved exactly

#### Scenario: Install into an rc that already has the block
- **WHEN** the installer runs against a `~/.zshrc` that already contains a managed block
- **THEN** it does not add a second block and does not duplicate the source line

### Requirement: Non-destructive migration of existing installs
When an existing hand-edited configuration is detected, the installer SHALL preserve it rather than replace it. User-defined lines SHALL be retained, either in place or relocated into the user customization layer, and no user content SHALL be deleted.

#### Scenario: Legacy configuration is migrated
- **WHEN** the installer finds a legacy antigen-based configuration
- **THEN** it creates a backup of the original `~/.zshrc`
- **AND** it preserves the user's custom lines in the user customization layer
- **AND** it installs the stable managed block
- **AND** it reports what was migrated and where

#### Scenario: Refusal to destroy
- **WHEN** the installer cannot determine how to preserve user content
- **THEN** it aborts without modifying `~/.zshrc`
- **AND** it explains the conflict and the manual step required

### Requirement: Idempotent install and update
Re-running install or update SHALL be safe. It SHALL not accumulate duplicate content, SHALL succeed when already up to date, and SHALL limit changes to framework-owned files.

#### Scenario: Install twice
- **WHEN** install is run a second time on an already-installed system
- **THEN** it completes successfully
- **AND** `~/.zshrc` is unchanged from after the first run
- **AND** the user customization layer is untouched

### Requirement: Uninstall removes only what it owns
Uninstall SHALL remove the managed block and framework-owned files without altering user-authored lines or the user customization layer.

#### Scenario: Uninstall preserves user content
- **WHEN** the user uninstalls the framework
- **THEN** the managed block is removed from `~/.zshrc`
- **AND** lines the user added outside the block remain
- **AND** the user customization layer remains on disk

### Requirement: Platform and prerequisite detection
The installer SHALL detect the operating system and package manager, SHALL verify a supported zsh version, and SHALL verify that required system dependencies (antidote, prompt) are installed and locatable. When a dependency is missing, it SHALL print platform-specific install instructions and exit non-zero, rather than failing obscurely. The framework SHALL NOT install system dependencies itself.

#### Scenario: Unsupported environment
- **WHEN** the installer runs on an unrecognized platform or with an unsupported zsh version
- **THEN** it exits non-zero
- **AND** it states the detected platform, the required minimum, and how to proceed

#### Scenario: Linux package manager detected
- **WHEN** the installer runs on a supported Linux distribution
- **THEN** it identifies the matching package manager and shows the exact install command for any missing dependency
- **AND** it does not run that command

#### Scenario: System dependency missing
- **WHEN** the installer finds that antidote or the prompt is not installed system-wide
- **THEN** it reports which dependency is missing
- **AND** it prints the platform-specific package or command to install it
- **AND** it does not install a per-user fallback copy

### Requirement: No privilege escalation by the framework
No script in the framework SHALL invoke `sudo`, `su`, `doas`, or otherwise attempt to elevate privileges, at install, update, or runtime. Any operation that would require elevated privileges SHALL be left to the user.

#### Scenario: Missing dependency requires manual action
- **WHEN** a required system dependency is missing
- **THEN** the framework fails with an actionable message and exits non-zero
- **AND** it does not attempt any privileged installation

#### Scenario: No privileged command in the codebase
- **WHEN** the repository's scripts are scanned
- **THEN** no privilege-escalation command is present

### Requirement: Validation before activation
The framework SHALL be syntax-checked before it becomes active. If validation fails, the previously working configuration SHALL remain in effect.

#### Scenario: Failed update leaves prior state usable
- **WHEN** an update introduces a syntax error detected during validation
- **THEN** the update is not activated
- **AND** the user's shell continues to start using the previous valid state

### Requirement: Diagnostics command
The framework SHALL provide a command that reports the installed version, the active entrypoint, detected user overrides, dependency status, and any detected problems.

#### Scenario: Doctor reports state
- **WHEN** the user runs the diagnostics command
- **THEN** it prints the framework version, entrypoint path, and the paths of user-layer files it found
- **AND** it reports missing dependencies or unreadable files as problems

## REMOVED Requirements

### Requirement: Stable version-invariant managed block
**Reason**: Distribution is delegated to chezmoi, which manages `~/.zshrc` as a normal file; there is no injected, version-invariant block.
**Migration**: Existing users run the new `install.sh`, which applies the chezmoi source. The existing `~/.zshrc` is backed up to `~/.zshrc.pre-chezmoi` on first apply, so the old block is recoverable.

## MODIFIED Requirements

### Requirement: Non-destructive migration of existing installs
The installer SHALL preserve an existing hand-edited shell configuration rather than silently replace it. On the first apply it SHALL copy any existing `~/.zshrc`, `~/.zshenv`, `~/.zprofile`, and `~/.zlogin` to the same name with a `.pre-chezmoi` suffix unless that backup already exists. The framework SHALL NOT attempt to parse or relocate a legacy configuration itself; documentation SHALL describe how to move personal settings into the untracked customization files.

#### Scenario: Legacy configuration is migrated
- **WHEN** the framework is applied on a machine with an existing hand-edited shell configuration
- **THEN** each existing shell file is copied to `<name>.pre-chezmoi` before any managed file is written
- **AND** the documentation describes how to move the previous personal settings into the untracked customization files
- **AND** the backup location is reported so the user can review it

#### Scenario: Refusal to destroy
- **WHEN** a managed file on disk differs from the source (drift)
- **THEN** the difference is reported by the diff/status command rather than applied silently
- **AND** the user can reconcile or re-apply deliberately

#### Scenario: No legacy parsing
- **WHEN** the framework is applied
- **THEN** it does not parse or classify a legacy antigen configuration

### Requirement: Idempotent install and update
Applying the configuration SHALL be idempotent. Re-applying or updating SHALL not accumulate duplicate content, SHALL succeed when already current, and SHALL limit changes to the managed file set. Updating SHALL refresh the source repository and re-apply it.

#### Scenario: Install twice
- **WHEN** the configuration is applied twice with no source change
- **THEN** the second apply makes no changes
- **AND** the drift report is empty
- **AND** files outside the managed set are untouched

#### Scenario: Update
- **WHEN** the user runs the update command
- **THEN** the source is refreshed and re-applied
- **AND** files outside the managed set are untouched

### Requirement: Uninstall removes only what it owns
Uninstalling SHALL remove the distribution tool's own configuration, state, and source without deleting user-authored configuration. Because shell files are installed as normal files, the user SHALL be told which installed files remain and may delete them.

#### Scenario: Uninstall preserves user content
- **WHEN** the user uninstalls/purges the framework
- **THEN** the distribution tool's configuration, state, and source are removed
- **AND** the installed shell files and the untracked customization files remain until the user deletes them

#### Scenario: Purge leaves targets
- **WHEN** the user runs the uninstall/purge command
- **THEN** the installed shell files remain on disk
- **AND** the untracked customization files are untouched

### Requirement: Platform and prerequisite detection
The framework SHALL support Linux and macOS, SHALL verify a supported zsh version, and SHALL verify that required system dependencies are installed and locatable: chezmoi, antidote, and Starship. When a dependency is missing it SHALL print platform-specific install instructions and SHALL NOT install it. The distribution tool SHALL be obtained from the operating system or Homebrew package manager, not from a mutable download endpoint.

#### Scenario: Unsupported environment
- **WHEN** the installer runs on an unrecognized platform or with an unsupported zsh version
- **THEN** it exits non-zero
- **AND** it states the detected platform, the required minimum, and how to proceed

#### Scenario: Linux package manager detected
- **WHEN** the installer runs on a supported Linux distribution
- **THEN** it identifies the matching package manager and shows the exact install command for any missing dependency
- **AND** it does not run that command

#### Scenario: System dependency missing
- **WHEN** chezmoi, antidote, or Starship is not installed
- **THEN** it reports which dependency is missing
- **AND** it prints the platform-specific package or command to install it
- **AND** it does not install the dependency itself

#### Scenario: macOS supported
- **WHEN** the configuration is applied on macOS with Homebrew-installed dependencies
- **THEN** it succeeds using the same source as on Linux

### Requirement: Diagnostics command
The framework SHALL provide diagnostics that report dependency status, the drift between the source and the installed files, and any problems.

#### Scenario: Doctor reports state
- **WHEN** the user runs the diagnostics command
- **THEN** it reports dependency status and problems
- **AND** the user can see whether installed files differ from the source

## ADDED Requirements

### Requirement: chezmoi-managed shell configuration
The repository SHALL be a chezmoi source directory. Installation SHALL apply that source to the user's home directory, and the managed set SHALL be `~/.zshenv`, `~/.zshrc`, the shell configuration directory (default `~/.config/zsh`), and `~/.config/starship.toml`. Files outside the managed set SHALL NOT be modified.

#### Scenario: Fresh install
- **WHEN** a user applies the source on a new machine
- **THEN** the managed shell files are installed
- **AND** unrelated files in the home directory are not modified

#### Scenario: Drift is visible before applying
- **WHEN** a managed file is edited directly
- **THEN** the drift is reported by the diff/status command before the next apply

### Requirement: Uninstall preserves the user layer
The untracked customization files SHALL NOT be part of the managed set and SHALL NOT be created, overwritten, or removed by installing, updating, or uninstalling the framework.

#### Scenario: Update does not touch the user layer
- **WHEN** the configuration is updated
- **THEN** `~/.config/zsh/local.zsh`, `~/.config/zsh/secrets.zsh`, and `~/.zshrc.local` are unchanged

# distribution Specification

## Purpose
Defines the practices that make the public, shared distribution safe and predictable for other people to install, upgrade, and depend on.

## Requirements

### Requirement: Versioned releases

The project SHALL publish versioned releases using semantic versioning. Every merge to the main branch SHALL be a release: it SHALL increment the version, record that version and its changes in the changelog, and produce both a git tag matching the version and a published release entry visible on the repository's releases page, so the version on the main branch always identifies the latest merged state. The increment SHALL be MAJOR for a breaking change, MINOR for a new or changed user-visible capability, and PATCH for a fix, documentation, or internal change. The checked-out release SHALL be discoverable from the source checkout, and users SHALL be able to pin or roll back by checking out a released tag in the source directory and re-applying.

#### Scenario: Runtime version report

- **WHEN** the user queries the installed version
- **THEN** the reported version corresponds to the checked-out release of the source

#### Scenario: Users can pin

- **WHEN** a user selects a specific released version
- **THEN** the documentation describes how to check out that tag in the source directory and re-apply

#### Scenario: Every merge is a release

- **WHEN** a change is merged to the main branch
- **THEN** the version is incremented, a changelog entry for the new version exists, and a git tag matches that version
- **AND** the version on the main branch identifies the latest merged state

#### Scenario: Bump level follows the change

- **WHEN** a merged change is breaking, adds or changes user-visible capability, or is only a fix, documentation, or internal change
- **THEN** the version bump is respectively MAJOR, MINOR, or PATCH

#### Scenario: The tag is actually created on merge

- **WHEN** a merge to the main branch records a new version
- **THEN** a git tag matching that version exists on the remote after the release automation runs
- **AND** the release automation does not fail for a missing committer identity

#### Scenario: The release is visible on the repository

- **WHEN** a merge to the main branch records a new version
- **THEN** a published release for that version exists and is visible on the repository's releases page
- **AND** its notes are taken from the changelog section for that version
- **AND** a git tag alone, without a published release, does not satisfy this requirement

#### Scenario: A failed release is detectable

- **WHEN** the release automation does not produce the tag or the published release for the merged version
- **THEN** the missing release is reported as a failure rather than left unnoticed

### Requirement: Changelog
The project SHALL maintain a changelog that records user-visible changes for each release, including breaking changes and required user actions.

#### Scenario: Breaking change is documented
- **WHEN** a release changes behavior users depend on
- **THEN** the changelog entry describes the change and the action the user must take

### Requirement: Deprecation before removal
A user-facing behavior SHALL NOT be removed without first emitting a deprecation warning in at least one prior release.

#### Scenario: Deprecation warning window
- **WHEN** a user-facing behavior is scheduled for removal
- **THEN** a prior release warns that it is deprecated and names the replacement
- **AND** the behavior still functions until the documented removal release

### Requirement: Continuous integration checks

The project's continuous integration SHALL verify, for repository changes: shell script linting, zsh syntax correctness, absence of committed secrets, absence of privilege-escalation commands, that a fresh install starts without errors, that re-applying is idempotent, that the fresh-install and shell-start checks pass on both Linux and macOS, and that a change destined for the main branch carries a new version and a matching changelog entry.

#### Scenario: Broken syntax is caught

- **WHEN** a change introduces a zsh syntax error
- **THEN** the syntax check fails and the change is blocked

#### Scenario: Privilege escalation is caught

- **WHEN** a change introduces a `sudo`, `su`, or `doas` invocation in a script
- **THEN** the check fails and the change is blocked

#### Scenario: Idempotency is verified

- **WHEN** the idempotency check applies the configuration twice in a clean environment
- **THEN** it confirms no drift after the second apply and no errors occur

#### Scenario: macOS is covered

- **WHEN** a change breaks the configuration on macOS only
- **THEN** the macOS job fails and the change is blocked

#### Scenario: Missing version bump is caught

- **WHEN** a change destined for the main branch does not carry a new version and changelog entry
- **THEN** the version check fails and the change is blocked

### Requirement: User-facing documentation
The README SHALL document installation, upgrading, customization, secrets handling, uninstallation, and supported platforms.

#### Scenario: New user can self-serve
- **WHEN** a new user follows the README alone
- **THEN** they can install, customize, and later upgrade without losing their configuration

### Requirement: Pinned dependencies and immutable sources
Dependencies SHALL be obtained from pinned or immutable sources, or from the operating system or Homebrew package manager, rather than from mutable download endpoints. The distribution tool, plugins, and frameworks SHALL be provided by the OS or Homebrew package manager wherever available.

#### Scenario: No mutable bootstrap URL
- **WHEN** the installer fetches a dependency
- **THEN** it uses a tagged release, a pinned commit, or a package manager
- **AND** it does not rely on a mutable shortcut URL

#### Scenario: Dependency supplied by the package manager
- **WHEN** a dependency is available in the OS package manager
- **THEN** the framework uses that system installation rather than downloading a per-user copy

#### Scenario: Dependencies come from package managers
- **WHEN** the configuration is installed
- **THEN** chezmoi, antidote, and Starship are expected to be installed by the OS or Homebrew package manager
- **AND** the framework does not download them from a mutable shortcut URL

#### Scenario: Installer does not vendor dependencies
- **WHEN** a dependency is missing
- **THEN** the framework instructs the user to install it with the package manager
- **AND** it does not install a per-user copy

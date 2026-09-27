## Purpose

Defines the practices that make the public, shared distribution safe and predictable for other people to install, upgrade, and depend on.

## ADDED Requirements

### Requirement: Versioned releases
The project SHALL publish versioned releases using semantic versioning and git tags, and the framework SHALL be able to report its version at runtime.

#### Scenario: Runtime version report
- **WHEN** the user queries the installed version
- **THEN** the reported version matches the most recent release tag that was installed

#### Scenario: Users can pin
- **WHEN** a user chooses to install a specific released version
- **THEN** the documentation describes how to check out and use that version

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
The project's continuous integration SHALL verify, for changes to the repository: shell script linting, zsh syntax correctness, absence of committed secrets, absence of privilege-escalation commands, that a fresh install starts without errors, and that re-running install is idempotent.

#### Scenario: Broken syntax is caught
- **WHEN** a change introduces a zsh syntax error
- **THEN** the syntax check fails and the change is blocked

#### Scenario: Privilege escalation is caught
- **WHEN** a change introduces a `sudo`, `su`, or `doas` invocation in a script
- **THEN** the check fails and the change is blocked

#### Scenario: Idempotency is verified
- **WHEN** the idempotency check runs install twice in a clean environment
- **THEN** it confirms the shell configuration is unchanged by the second run and no errors occur

### Requirement: User-facing documentation
The README SHALL document installation, upgrading, customization, secrets handling, uninstallation, and supported platforms.

#### Scenario: New user can self-serve
- **WHEN** a new user follows the README alone
- **THEN** they can install, customize, and later upgrade without losing their configuration

### Requirement: Pinned dependencies and immutable sources
Dependencies SHALL be obtained from pinned or immutable sources rather than mutable download endpoints, so that an install is reproducible and not vulnerable to upstream URL changes. Plugins and frameworks SHALL be provided by the operating system package manager wherever available.

#### Scenario: No mutable bootstrap URL
- **WHEN** the installer fetches a dependency
- **THEN** it uses a tagged release, a pinned commit, or a package manager
- **AND** it does not rely on a mutable shortcut URL

#### Scenario: Dependency supplied by the package manager
- **WHEN** a dependency is available in the OS package manager
- **THEN** the framework uses that system installation rather than downloading a per-user copy

## MODIFIED Requirements

### Requirement: Versioned releases
The project SHALL publish versioned releases using semantic versioning and git tags on the chezmoi source. The checked-out release SHALL be discoverable from the source checkout, and users SHALL be able to pin or roll back by checking out a released tag in the source directory and re-applying.

#### Scenario: Runtime version report
- **WHEN** the user queries the installed version
- **THEN** the reported version corresponds to the checked-out release of the source

#### Scenario: Users can pin
- **WHEN** a user selects a specific released version
- **THEN** the documentation describes how to check out that tag in the source directory and re-apply

### Requirement: Continuous integration checks
The project's continuous integration SHALL verify, for repository changes: shell script linting, zsh syntax correctness, absence of committed secrets, absence of privilege-escalation commands, that a fresh install starts without errors, that re-applying is idempotent, and that the fresh-install and shell-start checks pass on both Linux and macOS.

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

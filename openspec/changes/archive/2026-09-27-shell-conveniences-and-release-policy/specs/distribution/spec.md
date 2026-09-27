## MODIFIED Requirements

### Requirement: Versioned releases

The project SHALL publish versioned releases using semantic versioning and git tags on the chezmoi source. Every merge to the main branch SHALL be a release: it SHALL increment the version, record that version and its changes in the changelog, and produce a git tag matching the version, so the version on the main branch always identifies the latest merged state. The increment SHALL be MAJOR for a breaking change, MINOR for a new or changed user-visible capability, and PATCH for a fix, documentation, or internal change. The checked-out release SHALL be discoverable from the source checkout, and users SHALL be able to pin or roll back by checking out a released tag in the source directory and re-applying.

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

#### Scenario: A failed release is detectable

- **WHEN** the release automation does not produce the tag for the merged version
- **THEN** the missing tag is reported as a failure rather than left unnoticed

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

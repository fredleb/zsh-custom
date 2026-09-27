## Purpose

Defines how credentials are handled so that secrets never enter version control, never leak from installer backups, and are loaded only for the user who owns them.

## ADDED Requirements

### Requirement: No secrets in framework content
The framework SHALL NOT contain, ship, or export secret values. Any example or template file SHALL contain placeholders only.

#### Scenario: Template contains no real secret
- **WHEN** a user opens any shipped example or template
- **THEN** it contains only placeholders, never a usable credential

### Requirement: Supported per-user secrets file
The framework SHALL source a secrets file from the user customization layer when it exists. It SHALL document that the file must be readable only by its owner and SHALL warn when the file's permissions are too permissive.

#### Scenario: Secrets loaded when present
- **WHEN** a secrets file exists in the user customization layer
- **THEN** its contents are available to the shell session

#### Scenario: Missing secrets file is fine
- **WHEN** no secrets file exists
- **THEN** the shell starts normally without error

#### Scenario: Permissions warning
- **WHEN** the secrets file is readable by users other than its owner
- **THEN** the framework warns that the file should be restricted to the owner

### Requirement: Secrets excluded from version control and backups
The secrets file and other user-private files SHALL be excluded from version control. The installer's backup of an existing shell configuration SHALL occur before the framework injects anything, and documentation SHALL warn that pre-existing backups may contain secrets and should be reviewed.

#### Scenario: Secrets are never committed
- **WHEN** a user places their secrets file in the customization layer and runs a repository status check in the framework repo
- **THEN** the secrets file is not a candidate for commit

#### Scenario: Backup warning
- **WHEN** the installer backs up an existing shell configuration that contains credentials
- **THEN** it reports the backup path
- **AND** the documentation advises reviewing and removing any credentials from old backups

### Requirement: Automated secret scanning
The public repository's continuous integration SHALL scan commits and pull requests for secrets and SHALL fail the check when a secret is detected.

#### Scenario: Leaked secret fails CI
- **WHEN** a commit introduces a string matching a secret pattern
- **THEN** the secret-scanning check fails and blocks the change

### Requirement: Guidance to prefer credential helpers
Documentation SHALL recommend credential helpers or dedicated credential tools over exporting tokens as environment variables, and SHALL include migration guidance for users with tokens currently exported from their shell configuration.

#### Scenario: Migration guidance for exported tokens
- **WHEN** a user currently exports a token from their shell configuration
- **THEN** the documentation explains how to move it to the secrets layer or a credential helper
- **AND** advises rotating the exposed token

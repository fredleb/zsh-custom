# shell-conveniences Specification

## Purpose
Defines the shell conveniences the default configuration provides out of the box — directory listing and navigation, and interactive command history — so that they survive framework changes and stay overridable by the user.

## Requirements

### Requirement: Directory listing and navigation aliases

The default configuration SHALL provide the conventional directory-listing aliases `l`, `ll`, `la`, and `lsa`, and typing `..` SHALL change to the parent directory, without user configuration. Their definitions SHALL come from an upstream-maintained project rather than a hand-maintained alias list. The aliases and navigation SHALL be overridable by the user customization layer.

#### Scenario: Listing aliases are available by default

- **WHEN** a new shell starts with no user overrides
- **THEN** `l`, `ll`, `la`, and `lsa` list directory contents with the conventional long-format flags
- **AND** the user takes no action to enable them

#### Scenario: Parent-directory navigation works by default

- **WHEN** the user is in a directory and types `..`
- **THEN** the shell changes to the parent directory
- **AND** the user takes no action to enable it

#### Scenario: Definitions stay upstream-maintained

- **WHEN** the upstream source updates its definitions
- **THEN** the framework picks up the updated definitions on the next plugin refresh
- **AND** no hand-maintained alias list in this repository has to be edited

#### Scenario: User overrides win

- **WHEN** a user redefines a listing or navigation convenience in the untracked customization layer
- **THEN** the user's definition takes effect instead of the default

### Requirement: Interactive command history

The shell SHALL load and persist command history across sessions, so that pressing Up at the prompt recalls a previous command and Up and Down move through the recalled history. The shell SHALL share history between concurrent sessions.

#### Scenario: Recalling history

- **WHEN** the user presses Up at an empty prompt
- **THEN** a previously run command is shown
- **AND** pressing Up and Down moves through the history

#### Scenario: History persists across sessions

- **WHEN** the user starts a new shell
- **THEN** commands run in earlier sessions can be recalled

#### Scenario: History is shared between shells

- **WHEN** two shells are open at once
- **THEN** commands run in one can be recalled in the other

### Requirement: Space-prefixed commands are not recorded

The shell SHALL NOT add a command to history when the command line begins with a space, so that a user can run a command without recording it.

#### Scenario: Prefixed command is omitted from history

- **WHEN** the user runs a command whose line begins with a space
- **THEN** the command is not added to history
- **AND** it is not shown when the user recalls history afterwards

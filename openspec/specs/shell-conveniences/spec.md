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

### Requirement: Prefix history search

When the prompt contains text, pressing Up SHALL recall the most recent history
entry that begins with the text before the cursor, and each further press SHALL
move to an older matching entry. Pressing Down SHALL move to a newer matching
entry and, once past the newest match, SHALL restore the text the user had
typed. The search SHALL be provided by the shell's built-in line-editor widgets
rather than a hand-written search implementation. When the prompt is empty, or
the buffer spans more than one line, Up and Down SHALL keep their ordinary
history-recall and cursor-movement behavior. The bindings SHALL be installed
for both the emacs and vi editing modes, and SHALL be overridable by the user
customization layer.

#### Scenario: Prefix filters history

- **WHEN** the user types `opens` at the prompt and presses Up
- **THEN** the most recent history entry beginning with `opens` is shown
- **AND** pressing Up again shows an older entry beginning with `opens`

#### Scenario: Down returns to the typed line

- **WHEN** the user has typed `opens`, pressed Up to recall a match, and then
  presses Down until past the newest match
- **THEN** the prompt shows `opens` again

#### Scenario: Empty prompt keeps ordinary recall

- **WHEN** the prompt is empty and the user presses Up
- **THEN** the most recent history entry is shown, regardless of its text

#### Scenario: Non-matching prefix leaves the line unchanged

- **WHEN** the user types text that matches no history entry and presses Up
- **THEN** the line is left unchanged

#### Scenario: No wrapping past the oldest match

- **WHEN** the user keeps pressing Up after reaching the oldest entry beginning
  with the typed text
- **THEN** the oldest matching entry remains shown

#### Scenario: Repeated commands are not shown twice

- **WHEN** the same command occurs more than once in history and the user walks
  matching entries
- **THEN** that command is shown at most once during the walk

#### Scenario: Multi-line editing is not hijacked

- **WHEN** the buffer contains more than one line and the user presses Up
- **THEN** the cursor moves within the buffer
- **AND** no history search replaces the text

#### Scenario: Editing mode independence

- **WHEN** the shell runs in the vi editing mode (for example because `$EDITOR`
  contains `vi`) or the emacs editing mode
- **THEN** pressing Up with a typed prefix performs the same prefix search

#### Scenario: User overrides win

- **WHEN** a user rebinds Up or Down in the untracked customization layer
- **THEN** the user's definition takes effect instead of the default

#### Scenario: Definitions stay upstream-maintained

- **WHEN** the shell's upstream widgets change
- **THEN** the framework picks up the change on upgrade
- **AND** no hand-maintained search implementation in this repository has to be
  edited

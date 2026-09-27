## ADDED Requirements

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

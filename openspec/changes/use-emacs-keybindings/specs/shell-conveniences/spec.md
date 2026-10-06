## ADDED Requirements

### Requirement: Deliberate line-editor key map

The shell SHALL select the emacs key map for its line editor rather than
deriving it from `$EDITOR`/`$VISUAL`, so the standard emacs editing and history
keys are available. This SHALL include Ctrl-R for incremental reverse history
search and Ctrl-S for forward search, Ctrl-A/Ctrl-E for the line bounds,
Ctrl-W/Ctrl-K/Ctrl-U for deleting words or lines, and Ctrl-P/Ctrl-N for history
navigation. The key map SHALL be overridable by the user customization layer so
a user can select the vi key map instead.

#### Scenario: Ctrl-R searches the history

- **WHEN** the user presses Ctrl-R and types part of an earlier command
- **THEN** the matching previous command is recalled
- **AND** pressing Ctrl-R again continues to an older match

#### Scenario: Ctrl-S searches forward

- **WHEN** the user has searched backwards and presses Ctrl-S
- **THEN** the search moves to a newer match

#### Scenario: Standard emacs editing keys work

- **WHEN** the user presses Ctrl-A, Ctrl-E, Ctrl-W, Ctrl-K, Ctrl-U, Ctrl-P, or
  Ctrl-N
- **THEN** the key performs its emacs line-editing or history action

#### Scenario: Editing mode does not follow the editor

- **WHEN** `$EDITOR` contains `vi`
- **THEN** the shell still uses the emacs key map
- **AND** the emacs control keys work

#### Scenario: User can select the vi key map

- **WHEN** a user selects the vi key map in the untracked customization layer
- **THEN** the vi key map takes effect

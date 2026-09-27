## ADDED Requirements

### Requirement: Modified Delete keys

Pressing Shift+Delete, Ctrl+Delete, or Alt+Delete at the prompt SHALL delete
text rather than insert escape characters or change the editing mode.
Shift+Delete SHALL delete the character under the cursor, Ctrl+Delete SHALL
delete the following word, and Alt+Delete SHALL delete the preceding word. The
bindings SHALL be installed for the emacs and vi editing modes and SHALL be
overridable by the user customization layer.

#### Scenario: Shift+Delete deletes forward

- **WHEN** the cursor is in the middle of the line and the user presses
  Shift+Delete
- **THEN** the character under the cursor is removed
- **AND** the editing mode is unchanged

#### Scenario: Ctrl+Delete deletes the following word

- **WHEN** the cursor is at the start of a word and the user presses Ctrl+Delete
- **THEN** the word is removed

#### Scenario: Alt+Delete deletes the preceding word

- **WHEN** the cursor is at the end of a word and the user presses Alt+Delete
- **THEN** the word is removed

#### Scenario: Works in the vi insert mode

- **WHEN** the shell starts in the vi insert mode and the user presses one of
  these keys
- **THEN** the key deletes text
- **AND** the shell does not leave the insert mode

#### Scenario: User overrides win

- **WHEN** a user rebinds one of these keys in the untracked customization layer
- **THEN** the user's definition takes effect instead of the default

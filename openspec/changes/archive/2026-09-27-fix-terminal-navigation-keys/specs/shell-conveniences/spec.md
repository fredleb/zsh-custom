## ADDED Requirements

### Requirement: Terminal navigation keys

Pressing Delete, Home, End, Insert, PageUp, or PageDown at the prompt SHALL
perform that key's conventional line-editing action in every editing mode the
shell can start in (the emacs and vi insert modes), instead of inserting its
escape sequence or changing the editing mode. Delete SHALL delete the character
under the cursor; Home and End SHALL move the cursor to the start and end of the
line; Insert SHALL toggle overwrite mode; PageUp and PageDown SHALL move within
the buffer. The key sequences SHALL be derived from the terminal's advertised
capabilities where available, with well-known fallbacks for terminals that do
not advertise them, and a key the terminal does not provide SHALL be ignored
without error. The bindings SHALL be overridable by the user customization
layer.

#### Scenario: Delete deletes forward

- **WHEN** the cursor is in the middle of the line and the user presses Delete
- **THEN** the character under the cursor is removed
- **AND** the editing mode is unchanged

#### Scenario: Home and End move to the line bounds

- **WHEN** the user presses Home and then End
- **THEN** the cursor moves to the start of the line and then to its end

#### Scenario: Insert toggles overwrite

- **WHEN** the user presses Insert and types a character over existing text
- **THEN** the character is overwritten rather than inserted

#### Scenario: PageUp and PageDown move within the buffer

- **WHEN** the buffer spans more than one line and the user presses PageUp and
  PageDown
- **THEN** the cursor moves up and down within the buffer

#### Scenario: Works in the vi insert mode

- **WHEN** the shell starts in the vi insert mode (for example because `$EDITOR`
  contains `vi`) and the user presses one of these keys
- **THEN** the key performs its action
- **AND** the shell does not leave the insert mode

#### Scenario: Works in the emacs mode

- **WHEN** the shell starts in the emacs mode and the user presses one of these
  keys
- **THEN** the key performs its action instead of inserting escape characters

#### Scenario: Portable across terminals

- **WHEN** the terminal advertises different sequences for a key (for example a
  multiplexer that sends different Home and End sequences than xterm)
- **THEN** the key still performs its action

#### Scenario: Unavailable keys are ignored

- **WHEN** the terminal advertises no sequence for a key
- **THEN** the shell starts without error
- **AND** the other navigation keys still work

#### Scenario: User overrides win

- **WHEN** a user rebinds one of these keys in the untracked customization layer
- **THEN** the user's definition takes effect instead of the default

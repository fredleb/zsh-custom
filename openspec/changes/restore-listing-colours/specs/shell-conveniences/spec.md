## ADDED Requirements

### Requirement: Colourised directory listings

The directory listing provided by `ls` and the `l`, `ll`, `la`, and `lsa`
aliases SHALL render file names in colour when standard output is an
interactive terminal. Colour SHALL be produced with the listing command
available on the platform, so that the configuration introduces no new system
dependency. When output is piped or redirected, the listing SHALL contain no
colour escape sequences. The colour definitions SHALL come from an
upstream-maintained project rather than a hand-maintained palette or alias
list, and SHALL be overridable by the user customization layer.

#### Scenario: Listing is coloured at a terminal

- **WHEN** the user runs `ls`, `l`, `ll`, `la`, or `lsa` at an interactive terminal
- **THEN** file names are rendered in colour
- **AND** the user takes no action to enable it

#### Scenario: Piped output stays plain

- **WHEN** the output of a listing alias is piped to another command or
  redirected to a file
- **THEN** the output contains no colour escape sequences

#### Scenario: Works with the platform's stock listing command

- **WHEN** the shell runs on Linux or macOS with only the platform's own
  listing command installed
- **THEN** listings are coloured
- **AND** no additional tool has to be installed

#### Scenario: Definitions stay upstream-maintained

- **WHEN** the upstream source updates its colour definitions
- **THEN** the configuration picks up the updated definitions on the next
  plugin refresh
- **AND** no hand-maintained palette in this repository has to be edited

#### Scenario: User overrides win

- **WHEN** a user disables or redefines the listing colour in the untracked
  customization layer
- **THEN** the user's definition takes effect instead of the default

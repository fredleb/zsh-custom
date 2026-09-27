## ADDED Requirements

### Requirement: No imposed XDG base-directory defaults

The framework SHALL NOT set the XDG base-directory variables `XDG_CONFIG_HOME`,
`XDG_CACHE_HOME`, or `XDG_DATA_HOME` to default values in the shell
environment. It SHALL honor values the user has already set and SHALL resolve
its own managed paths from them, falling back to the standard locations
(`~/.config`, `~/.cache`, `~/.local/share`) when they are unset. Setting these
variables to defaults is not neutral: tools that treat them as overrides rather
than fall back can be redirected away from their existing data.

#### Scenario: Defaults are not imposed

- **WHEN** a shell starts with none of the XDG base-directory variables set
- **THEN** the framework does not set them
- **AND** the managed configuration is still loaded from the standard locations

#### Scenario: User-supplied values are honored

- **WHEN** the user sets `XDG_CONFIG_HOME` (or the cache or data variable)
- **THEN** the framework resolves its managed paths from the user's value
- **AND** it does not override that value

#### Scenario: A tool's non-XDG home is preserved

- **WHEN** the user has not set the XDG variables and a tool derives its home
  directory from an XDG variable only when that variable is set
- **THEN** starting the shell leaves the tool's non-XDG home directory unchanged
- **AND** the tool continues to find the data it had before

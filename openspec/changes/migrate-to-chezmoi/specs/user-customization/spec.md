## MODIFIED Requirements

### Requirement: Dedicated user customization layer
The framework SHALL define a user customization layer consisting of untracked files that the distribution tool never manages: `~/.config/zsh/local.zsh`, `~/.config/zsh/secrets.zsh`, and `~/.zshrc.local`. The framework SHALL NOT create these files or overwrite them; documentation SHALL show how to create them. They SHALL NOT be part of the managed set.

#### Scenario: Untouched by updates
- **WHEN** a user maintains settings in the customization files and the framework is updated
- **THEN** those files are unchanged and still loaded

#### Scenario: Not created by the framework
- **WHEN** the framework is applied on a machine without customization files
- **THEN** the shell starts normally
- **AND** the framework does not create them

### Requirement: Deterministic load ordering
The managed entrypoint SHALL source framework fragments in lexical order, then the general customization file, then the final escape-hatch file, so that user configuration overrides framework defaults.

#### Scenario: User overrides a default
- **WHEN** the user sets a value in the customization file that also has a framework default
- **THEN** the user's value is effective

#### Scenario: Missing override files are fine
- **WHEN** a customization file is absent
- **THEN** the shell still starts without error

### Requirement: Plugin and prompt extension points
The framework SHALL allow additional plugins and prompt customization without editing managed files, by loading a user plugin list from the customization file and by allowing prompt configuration to be overridden.

#### Scenario: Extension points are honored
- **WHEN** the user adds plugins or prompt configuration through the customization layer
- **THEN** both take effect alongside the framework defaults

### Requirement: Discoverability
Documentation SHALL name the exact files to edit for plugins, prompt, secrets, and general configuration, and the drift/diagnostics commands SHALL help users locate the managed source of a file.

#### Scenario: New user finds the entry points
- **WHEN** a user reads the documentation
- **THEN** they can identify the exact file paths to edit for plugins, prompt, secrets, and general configuration

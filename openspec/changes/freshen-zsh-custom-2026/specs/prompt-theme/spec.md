## Purpose

Defines the shell prompt: a maintained, configurable prompt that reproduces the context information the previous custom theme provided.

## ADDED Requirements

### Requirement: Maintained prompt implementation
The prompt SHALL be provided by Starship and configured declaratively. The previous custom zsh theme SHALL be removed.

#### Scenario: Prompt comes from Starship
- **WHEN** a new shell starts
- **THEN** the prompt is rendered by Starship
- **AND** no custom theme file is sourced

### Requirement: Context information in the prompt
The prompt SHALL display, when relevant: current user and host, an abbreviated working directory, the git branch with ahead/behind indicators and staged/unstaged/untracked state, a non-zero exit-status indicator, and the current time.

#### Scenario: Git repository context
- **WHEN** the user is inside a git repository with local changes and commits ahead of upstream
- **THEN** the prompt shows the branch, the ahead indicator, and the dirty state

#### Scenario: Failure exit status
- **WHEN** the previously run command exits non-zero
- **THEN** the prompt indicates the failure and the exit code

#### Scenario: Outside a repository
- **WHEN** the user is not inside a git repository
- **THEN** the prompt omits git information without error

### Requirement: Runtime version context
The prompt SHALL display the active Node.js version when a Node runtime is active via the environment manager.

#### Scenario: Node active
- **WHEN** an nvm-managed Node version is active
- **THEN** the prompt shows that version

### Requirement: Readable without special fonts
The prompt SHALL remain usable in terminals that do not have a Nerd Font installed, and icon usage SHALL be configurable.

#### Scenario: No Nerd Font
- **WHEN** the terminal lacks a Nerd Font
- **THEN** the prompt still displays readable text without garbled glyphs

### Requirement: User prompt customization survives updates
Users SHALL be able to override prompt configuration from the user customization layer, and that override SHALL continue to apply across framework updates.

#### Scenario: User overrides prompt
- **WHEN** a user places a prompt configuration in their customization layer
- **THEN** the shell uses that configuration
- **AND** updating the framework does not replace it

### Requirement: Prompt colors and spacing
The prompt SHALL render the host, time, runtime, and git elements in the terminal's default foreground color so they stay readable on both light and dark backgrounds. The host name SHALL be colored only for remote (SSH) sessions. The prompt SHALL emit exactly one space after the prompt character.

#### Scenario: Local session uses the default foreground
- **WHEN** the shell runs in a local (non-SSH) session
- **THEN** the host, time, node, and git elements are shown in the terminal's default foreground color
- **AND** the host name is not colored

#### Scenario: Remote session colors the host
- **WHEN** the shell runs over SSH
- **THEN** the host name is displayed in blue

#### Scenario: Exactly one space after the prompt character
- **WHEN** the prompt is rendered
- **THEN** there is exactly one space after the prompt character

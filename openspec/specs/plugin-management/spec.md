# plugin-management Specification

## Purpose
Defines how zsh plugins are declared and loaded: a curated, maintained default set managed by antidote, extensible by users without editing framework files.

## Requirements

### Requirement: Antidote as the plugin manager
The framework SHALL manage plugins with antidote and SHALL NOT depend on antigen. Antidote SHALL be resolved from a **system-wide installation** and SHALL NOT require a per-user clone; the framework SHALL locate the packaged entrypoint and source it. The shell SHALL load plugins from a declarative list rather than an imperative bootstrapping script.

#### Scenario: Plugins load from a declarative list
- **WHEN** a new shell starts
- **THEN** the declared plugins are loaded without any antigen commands being required

#### Scenario: System antidote is used
- **WHEN** a new shell starts on a system where antidote is installed by the package manager
- **THEN** the framework sources the packaged antidote entrypoint
- **AND** it does not clone or source a per-user antidote copy

#### Scenario: Antigen is fully removed
- **WHEN** the framework is installed
- **THEN** no file references antigen or its cache

### Requirement: Curated maintained default plugin set
The framework SHALL ship a default plugin set consisting of maintained FOSS plugins: extra completions, autosuggestions, syntax highlighting, and git convenience. Syntax highlighting SHALL be ordered after the other plugins that mutate the command line. The default set SHALL NOT require loading the full oh-my-zsh library.

#### Scenario: Default plugins are active
- **WHEN** a new shell starts with no user overrides
- **THEN** completion, autosuggestion, and syntax highlighting behaviors are active
- **AND** the full oh-my-zsh framework is not loaded

#### Scenario: Ordering is respected
- **WHEN** plugins are loaded
- **THEN** syntax highlighting is loaded after autosuggestions and completions

### Requirement: User plugin extension
The framework SHALL load an additional plugin list from the user customization layer, after the default set, so users can add plugins without modifying framework-owned files.

#### Scenario: User adds a plugin
- **WHEN** a user adds a plugin entry to their user plugin file
- **THEN** that plugin is loaded in addition to the defaults
- **AND** no framework-owned file is modified

### Requirement: Fail-soft plugin loading
Failure to fetch or load a plugin SHALL NOT prevent the shell from starting. The framework SHALL warn about the failed plugin and continue.

#### Scenario: Unreachable plugin
- **WHEN** a declared plugin cannot be fetched
- **THEN** the shell still starts successfully
- **AND** a warning naming the plugin is shown once

### Requirement: Cached plugin resolution with refresh
The framework SHALL avoid re-resolving the full plugin set on every shell start by using a cached/compiled representation, and SHALL provide a way to refresh that cache after changing plugin lists.

#### Scenario: Cache is reused across shells
- **WHEN** two shells start in a row without plugin changes
- **THEN** the second start does not recompute the plugin resolution

#### Scenario: Refresh after change
- **WHEN** the user changes a plugin list and runs the refresh command
- **THEN** subsequent shells load the updated set

### Requirement: Interactive completion menu
The completion system SHALL present a selectable menu when the user requests completion repeatedly, SHALL allow moving the selection with the arrow keys, and SHALL highlight the selected candidate. The candidate list SHALL be colorized.

#### Scenario: Repeated completion opens a menu
- **WHEN** the user presses Tab to complete an ambiguous word
- **THEN** the candidates are listed
- **WHEN** the user presses Tab again
- **THEN** a selection menu is shown with a candidate highlighted

#### Scenario: Arrow keys move the selection
- **WHEN** the completion menu is open and the user presses an arrow key
- **THEN** the highlighted candidate changes
- **AND** the command is not executed until the user accepts or dismisses the menu

#### Scenario: Menu styles match the previous configuration
- **WHEN** a shell starts with the framework defaults
- **THEN** the `zsh/complist` module is loaded
- **AND** the `menu` style is set to `select` for completion contexts
- **AND** the completion list is colorized

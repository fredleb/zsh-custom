## Purpose

Defines the supported, update-proof place where users and sites customize the shell, so that pulling a new framework version never removes their configuration.

## ADDED Requirements

### Requirement: Dedicated user customization layer
The framework SHALL define a user customization directory (default under the user's config home) that is owned by the user and separate from the framework. The installer SHALL create it from a template when missing and SHALL NOT overwrite files that already exist in it.

#### Scenario: Created once, then left alone
- **WHEN** the installer runs on a system without a user customization layer
- **THEN** it creates the layer from a template
- **WHEN** the installer runs again after the user has edited that layer
- **THEN** the user's files are unchanged

#### Scenario: User edits survive framework update
- **WHEN** the user has placed configuration in the customization layer and then updates the framework
- **THEN** the user's configuration is still present and still loaded

### Requirement: Deterministic load ordering
Framework defaults SHALL load before user customization. User configuration fragments SHALL load in lexical order, and a final escape-hatch file SHALL load last, so that user configuration can override framework defaults.

#### Scenario: User overrides a default
- **WHEN** the user defines a setting in their customization layer that also has a framework default
- **THEN** the user's value is the effective value

#### Scenario: Underscore-prefixed fragments
- **WHEN** the user renames a fragment so it is no longer picked up
- **THEN** the fragment is not loaded
- **AND** the shell still starts without error

### Requirement: Plugin and prompt extension points
The user customization layer SHALL provide extension points for additional plugins and for prompt configuration.

#### Scenario: Extension points are honored
- **WHEN** the user adds plugins or prompt configuration in the customization layer
- **THEN** both take effect alongside the framework defaults

### Requirement: Discoverability
The framework SHALL document the customization layer and its extension points, and SHALL ship template files as a starting point. The diagnostics command SHALL report which user-layer files were found.

#### Scenario: New user finds the entry points
- **WHEN** a user reads the documentation or runs diagnostics
- **THEN** they can identify the exact file paths to edit for plugins, prompt, secrets, and general configuration

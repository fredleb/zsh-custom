# Agent Instructions

Project-specific rules for AI agents and automation working in this repository.
See `openspec/` for the workspace specifications and workflow.

## Review and merge authority

- Make CI pass. Do not merge.
- A human maintainer reviews every pull request and performs the merge. Opening
  a pull request does not imply consent to merge it.
- Agents MAY create branches, commit, push, open or update pull requests, and
  push further commits to fix failing checks.
- Agents SHALL NOT merge a pull request, close it, or force-push over review
  without explicit human consent.

Codified as the "Human review and merge authority" requirement in
`openspec/specs/distribution/spec.md`.

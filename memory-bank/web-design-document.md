# Skill Design Document

## Goal

Provide a small, safe Skill package that helps Codex and Claude Code use `codex-provider-sync` without guessing or manually editing Codex local state.

## Target Users

- Codex Desktop / CLI users who switch provider/API profiles.
- CC Switch users whose historical Codex sessions disappear after switching provider.
- AI agents that need a precise workflow for status, sync, verify, and restore.

## MVP Scope

- Publish a valid Skill under `skills/codex-provider-sync`.
- Provide install and verify scripts.
- Provide plugin metadata for local plugin managers.
- Document safety boundaries and restore path.

## Non-Goals

- Reimplement the upstream `codex-provider-sync` CLI.
- Manage credentials, API keys, OAuth files, or `auth.json`.
- Force provider switching as the default workflow.
- Mutate session content or re-encrypt encrypted histories.

## Success Criteria

- Skill validates with Codex `quick_validate.py`.
- `scripts/verify.ps1` checks plugin metadata, Skill frontmatter, Node 24+, CLI presence, and read-only status.
- README makes the difference between project sync and provider/session sync explicit.
- Agents default to inspect-first and backup-aware operation.

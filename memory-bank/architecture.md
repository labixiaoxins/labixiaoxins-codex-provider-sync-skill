# Architecture

## Components

- `.codex-plugin/plugin.json`: Local plugin metadata for plugin managers.
- `skills/codex-provider-sync/SKILL.md`: Agent-facing workflow loaded when the skill triggers.
- `scripts/install.ps1`: Installs the upstream CLI and copies the Skill/wrapper into local agent directories.
- `scripts/verify.ps1`: Validates repo structure, runtime prerequisites, CLI availability, and optional read-only Codex status.
- `agent-tools/codex-provider-sync.cmd`: Thin Windows wrapper around `codex-provider`.
- `README.md`: Public user-facing documentation.

## State Boundaries

This package does not own Codex state. It delegates state mutation to upstream `codex-provider-sync`, which creates managed backups before sync/switch operations.

The Skill must keep these boundaries explicit:

- Never touch `auth.json`.
- Never copy provider credentials.
- Never manually edit rollout files or SQLite if the upstream CLI can handle the repair.
- Always inspect before syncing.
- Use restore when a sync target is wrong.

## Related Tool Boundary

`codex-project-sync` owns project registration recovery: roots, trust entries, labels, order, and active roots.

`codex-provider-sync-skill` owns provider/session visibility repair: rollout metadata, SQLite metadata, provider counts, user-event flags, and cwd repair.

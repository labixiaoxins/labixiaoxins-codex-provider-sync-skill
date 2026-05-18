# codex-provider-sync-skill

Codex / Claude Code Skill package for safely using [`Dailin521/codex-provider-sync`](https://github.com/Dailin521/codex-provider-sync) after Codex provider/API switches.

It gives AI agents a small, backup-aware runbook for restoring historical Codex session visibility when sessions still exist locally but disappear from Codex Desktop, `/resume`, or project history after `model_provider` changes.

## What It Solves

Codex provider config, rollout metadata, SQLite thread metadata, and project path caches can drift after a provider/API switch. Common symptoms:

- Old sessions exist on disk but do not appear in Codex Desktop.
- `/resume` misses older conversations.
- Project history is empty or incomplete.
- Rollout provider metadata, SQLite rows, and cwd paths disagree.

This package does not replace the upstream CLI. It wraps it with agent-facing instructions, install helpers, and a conservative workflow:

```text
status -> sync only if needed -> status again -> restore if wrong
```

## Boundaries

This package can help with:

- Inspecting current Codex provider/session metadata alignment.
- Repairing historical session visibility metadata.
- Repairing SQLite user-event flags and cwd paths through the upstream CLI.
- Keeping backup and restore steps visible to the agent.

This package does not:

- Log in to OpenAI, GitHub, or third-party providers.
- Manage `auth.json`, API keys, provider tokens, or OAuth files.
- Rewrite conversation content, titles, or message history.
- Re-encrypt `encrypted_content`; old encrypted sessions may become visible but can still fail when continued under a different provider/account.

## Requirements

- Node.js `24+` because the upstream CLI uses `node:sqlite`.
- `npm` available on PATH.
- Codex local state under one of:
  - `$env:CODEX_HOME`
  - `%USERPROFILE%\.codex`
  - an explicit `--codex-home <path>`

The current package was validated against upstream `codex-provider-sync@0.2.5`.

## Quick Install

From this repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

The installer:

- Checks Node.js major version.
- Installs or updates the upstream `codex-provider` CLI.
- Copies the Skill into your Codex skill directory.
- Optionally copies it into shared agent / Claude Code skill directories when those directories exist.
- Installs the Windows wrapper into `~/agent-tools`.

Then verify:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1
```

## Manual Install

Install the upstream CLI:

```powershell
npm install -g git+https://github.com/Dailin521/codex-provider-sync.git
```

Copy the Skill:

```powershell
$codexSkills = if ($env:CODEX_HOME) { Join-Path $env:CODEX_HOME 'skills' } else { Join-Path $env:USERPROFILE '.codex\skills' }
New-Item -ItemType Directory -Force -Path $codexSkills | Out-Null
Copy-Item -Recurse -Force .\skills\codex-provider-sync (Join-Path $codexSkills 'codex-provider-sync')
```

Optional wrapper:

```powershell
New-Item -ItemType Directory -Force -Path (Join-Path $env:USERPROFILE 'agent-tools') | Out-Null
Copy-Item -Force .\agent-tools\codex-provider-sync.cmd (Join-Path $env:USERPROFILE 'agent-tools\codex-provider-sync.cmd')
```

## Recommended Workflow

Resolve Codex home:

```powershell
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
```

Inspect first:

```powershell
codex-provider status --codex-home $codexHome
```

Run sync only when the current provider is correct and the report shows mixed providers, user-event repairs, cwd repairs, or project visibility mismatch:

```powershell
codex-provider sync --keep 5 --codex-home $codexHome
```

Verify:

```powershell
codex-provider status --codex-home $codexHome
```

If the result is wrong, restore from the backup path printed by `sync`:

```powershell
codex-provider restore <backup-dir> --codex-home $codexHome
```

## When To Use `switch`

Prefer switching providers with your normal provider tool, then use this Skill for metadata repair.

Only use the upstream switch command when the user explicitly asks this tool to change Codex provider and the target provider is already declared in Codex config:

```powershell
codex-provider switch <provider-id> --keep 5 --codex-home $codexHome
```

## With codex-project-sync

Use the two tools for different state layers:

- `codex-project-sync`: project roots, trust entries, labels, project order, active workspace roots.
- `codex-provider-sync`: rollout files, SQLite thread metadata, provider/session visibility, cwd repair.

After a CC Switch provider/API change, a conservative sequence is:

```powershell
sync-codex-projects.cmd sync
codex-provider-sync.cmd status --codex-home $codexHome
```

Only run provider `sync` if `status` says metadata needs repair.

## Troubleshooting

| Symptom | Action |
| --- | --- |
| `node:sqlite` error | Install Node.js 24+. |
| SQLite is locked | Close Codex Desktop, Codex CLI, and app-server, then retry. |
| Locked rollout files skipped | Treat as partial success; rerun after the active session ends. |
| `encrypted_content` warning | Visibility can be repaired, but continuing old encrypted sessions under another provider/account may fail. |
| Desktop still misses old sessions | Check whether Codex Desktop is only loading the recent first page; use CLI `/resume` as a second signal. |
| Wrong sync target | Use `codex-provider restore <backup-dir>`. |

## Repository Layout

```text
.
├── .codex-plugin/plugin.json
├── agent-tools/codex-provider-sync.cmd
├── memory-bank/
├── scripts/install.ps1
├── scripts/verify.ps1
└── skills/codex-provider-sync/SKILL.md
```

## License

This Skill package is MIT licensed. The upstream CLI is maintained separately at [`Dailin521/codex-provider-sync`](https://github.com/Dailin521/codex-provider-sync); follow its license and release notes.

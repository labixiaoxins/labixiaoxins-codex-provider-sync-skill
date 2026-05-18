---
name: codex-provider-sync
description: Repair Codex historical session visibility after switching model_provider/API/provider. Use when CC Switch or another provider tool changes Codex provider and old sessions disappear from Codex Desktop, /resume, project history, or local session lists; also use to inspect provider/session metadata alignment before or after switching providers.
---

# Codex Provider Sync

Use this skill to run the local `codex-provider-sync` CLI installed from `https://github.com/Dailin521/codex-provider-sync`.

## What It Fixes

- Historical Codex sessions hidden after `model_provider` changes.
- Rollout metadata under `~/.codex/sessions` and `~/.codex/archived_sessions`.
- SQLite thread metadata in `~/.codex/state_5.sqlite`.
- Project visibility metadata in `.codex-global-state.json`.

## What It Does Not Fix

- It does not log in, switch accounts, or manage `auth.json`.
- It does not copy API keys or provider credentials.
- It does not rewrite message content, titles, or conversation history.
- It does not re-encrypt `encrypted_content`; old encrypted sessions may become visible but still fail if continued under a different provider/account.

## Default Workflow

1. Inspect first:

```powershell
codex-provider status --codex-home C:\Users\Administrator\.codex
```

2. If the current provider is correct and metadata needs repair:

```powershell
codex-provider sync --keep 5 --codex-home C:\Users\Administrator\.codex
```

3. Verify:

```powershell
codex-provider status --codex-home C:\Users\Administrator\.codex
```

4. If switching provider directly through this tool, only use `switch <provider-id>` when the target provider is already declared in `~/.codex/config.toml`:

```powershell
codex-provider switch <provider-id> --keep 5 --codex-home C:\Users\Administrator\.codex
```

## Safety Rules

- Prefer `status` before any write.
- Do not manually edit rollout files or `state_5.sqlite` if this CLI can handle the repair.
- Treat backups under `C:\Users\Administrator\.codex\backups_state\provider-sync` as private local artifacts.
- If SQLite is locked, tell the user to close Codex Desktop, Codex CLI, and app-server, then retry.
- If locked rollout files are skipped, treat the run as partially successful and rerun after the active session ends if a full rewrite is needed.

## Pair With codex-project-sync

- Run `codex-provider-sync` for session visibility/provider metadata.
- Run `codex-project-sync` for project roots, trust entries, labels, and ordering.

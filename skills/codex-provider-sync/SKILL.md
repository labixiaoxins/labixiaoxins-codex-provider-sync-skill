---
name: codex-provider-sync
description: Repair or inspect Codex historical session visibility after model_provider/API/provider changes. Use when CC Switch or another provider tool changes Codex provider and old sessions disappear from Codex Desktop, /resume, project history, or local session lists; use before and after provider switches to inspect rollout/SQLite/project visibility metadata; use restore guidance when a previous sync targeted the wrong provider.
---

# Codex Provider Sync

Use this skill to run the upstream `codex-provider` CLI from `Dailin521/codex-provider-sync` with a conservative status-first workflow.

## Resolve Paths

Use this Codex home unless the user provides another path:

```powershell
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
```

Use this wrapper when it exists:

```powershell
$wrapper = Join-Path $env:USERPROFILE 'agent-tools\codex-provider-sync.cmd'
```

Fallback to `codex-provider` directly when the wrapper is missing.

## Default Workflow

1. Inspect first:

```powershell
codex-provider status --codex-home $codexHome
```

2. Only sync if the current provider is correct and the status output reports mixed providers, user-event repairs, cwd repairs, or project visibility mismatch:

```powershell
codex-provider sync --keep 5 --codex-home $codexHome
```

3. Verify after sync:

```powershell
codex-provider status --codex-home $codexHome
```

4. Report the current provider, whether rollout and SQLite metadata are aligned, and the backup directory printed by sync.

## Restore

If sync targeted the wrong provider or the user wants to roll back, use the backup path printed by the sync command:

```powershell
codex-provider restore <backup-dir> --codex-home $codexHome
```

Do not guess the backup directory. List `backups_state\provider-sync` only when the user asks or the exact path is missing.

## Provider Switching

Prefer the user's normal provider tool for provider/API switching. Only run this command when the user explicitly asks this skill to change Codex provider and the target provider already exists in Codex config:

```powershell
codex-provider switch <provider-id> --keep 5 --codex-home $codexHome
```

If the provider is missing, tell the user to define or switch it through their provider tool first, then run `sync`.

## Safety Rules

- Prefer `status` before any write.
- Do not run `sync` just because the user mentions provider switching; inspect first.
- Do not manually edit rollout files or `state_5.sqlite` if the CLI can handle the repair.
- Treat backups under `<codex-home>\backups_state\provider-sync` as private local artifacts.
- Never read, print, copy, or modify `auth.json`, API keys, provider tokens, or OAuth files.
- If SQLite is locked, tell the user to close Codex Desktop, Codex CLI, and app-server, then retry.
- If locked rollout files are skipped, report partial success and rerun after the active session ends if the user wants a full rewrite.
- If `encrypted_content` warnings appear, explain that visibility metadata can be synchronized but continuing those old encrypted sessions under another provider/account may still fail.

## Pair With codex-project-sync

- Use `codex-provider-sync` for session visibility, rollout metadata, SQLite thread metadata, and cwd repair.
- Use `codex-project-sync` for project roots, trust entries, labels, active roots, and project ordering.

After CC Switch provider/API changes, restore project registrations first, then inspect provider/session metadata:

```powershell
sync-codex-projects.cmd sync
codex-provider status --codex-home $codexHome
```

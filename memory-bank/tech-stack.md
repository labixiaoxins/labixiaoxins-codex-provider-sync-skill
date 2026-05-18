# Tech Stack

## Package Shape

- Markdown for public documentation and Skill instructions.
- PowerShell for Windows-first install and verification scripts.
- JSON for `.codex-plugin/plugin.json`.
- Upstream Node.js CLI: `Dailin521/codex-provider-sync`.

## Runtime Assumptions

- Node.js 24+ is required by the upstream CLI because it uses `node:sqlite`.
- npm is used only to install the upstream CLI.
- Codex state defaults to `$env:CODEX_HOME` or `%USERPROFILE%\.codex`.

## Maintenance Rules

- Keep `SKILL.md` concise and operational.
- Put user-facing installation and troubleshooting in `README.md`.
- Put durable design decisions in `memory-bank`.
- Do not store user-specific secrets, session data, or backups in this repository.

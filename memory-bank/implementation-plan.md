# Implementation Plan

1. Add full plugin metadata.
   - Verification: parse `.codex-plugin/plugin.json` as JSON.

2. Add portable install script.
   - Verification: run with `-SkipNpmInstall` when CLI already exists; confirm Skill and wrapper copy paths.

3. Add portable verify script.
   - Verification: run `scripts/verify.ps1` and confirm it performs read-only status.

4. Rewrite README for public installation and troubleshooting.
   - Verification: inspect rendered Markdown structure and command examples.

5. Rewrite SKILL.md for status-first operation.
   - Verification: run Codex `quick_validate.py`.

6. Add memory-bank docs.
   - Verification: confirm design, architecture, tech stack, and progress docs exist.

7. Commit and publish to GitHub.
   - Verification: fetch README and SKILL.md from GitHub after upload.

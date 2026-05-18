# codex-provider-sync-skill

面向 Codex / Claude Code 的本地 Skill 包，用来调用 [`Dailin521/codex-provider-sync`](https://github.com/Dailin521/codex-provider-sync)，修复 Codex 在切换 `model_provider` / API / Provider 之后，历史会话在 Desktop、`/resume` 或项目侧列表里不可见的问题。

## 解决的问题

Codex 的 provider 配置、rollout 会话 metadata、SQLite thread metadata、项目路径缓存可能不是同一个状态源。用 CC Switch 或其他工具切换 Provider 后，经常会出现：

- 旧会话还在本地，但 Codex Desktop 看不到。
- `/resume` 里缺少旧会话。
- 项目侧历史会话为空或数量不对。
- 会话 provider metadata、SQLite rows、cwd path 不一致。

这个 Skill 的作用是让 AI Agent 按安全流程调用 `codex-provider` CLI：先 `status`，再在必要时 `sync`，最后复查。

## 能力边界

会做：

- 检查当前 Codex provider。
- 检查 rollout files 与 SQLite metadata 是否对齐。
- 修复历史会话 provider/session visibility metadata。
- 修复 SQLite user-event flags 与 cwd paths。
- 使用上游工具自动创建备份。

不会做：

- 不登录 GitHub / OpenAI / 第三方 API。
- 不管理 `auth.json`。
- 不复制 API key、provider token 或 OAuth 文件。
- 不改写对话正文、标题或消息内容。
- 不重新加密 `encrypted_content`。旧加密会话可能恢复“可见”，但跨 provider/account 继续对话仍可能失败。

## 前置要求

- Windows 10/11 或可运行 Node.js 的环境。
- Node.js `24+`，因为上游 CLI 使用 `node:sqlite`。
- 已安装上游 CLI：

```powershell
npm install -g git+https://github.com/Dailin521/codex-provider-sync.git
```

## 安装 Skill

把本仓库里的 Skill 复制到 Codex Skill 目录：

```powershell
Copy-Item -Recurse -Force .\skills\codex-provider-sync C:\Users\Administrator\.codex\skills\codex-provider-sync
```

可选：同步到 Claude Code / 共享 Skill 目录：

```powershell
Copy-Item -Recurse -Force .\skills\codex-provider-sync C:\Users\Administrator\.agents\skills\codex-provider-sync
Copy-Item -Recurse -Force .\skills\codex-provider-sync C:\Users\Administrator\.claude\skills\codex-provider-sync
```

可选：安装 Windows wrapper：

```powershell
Copy-Item -Force .\agent-tools\codex-provider-sync.cmd C:\Users\Administrator\agent-tools\codex-provider-sync.cmd
```

## 推荐使用流程

先只读检查：

```powershell
codex-provider status --codex-home C:\Users\Administrator\.codex
```

如果当前 provider 是正确的，但报告显示 mixed providers、`user-event flags needing repair`、`cwd paths needing repair` 或项目可见性异常，再运行：

```powershell
codex-provider sync --keep 5 --codex-home C:\Users\Administrator\.codex
```

最后复查：

```powershell
codex-provider status --codex-home C:\Users\Administrator\.codex
```

如果安装了 wrapper，也可以用：

```powershell
C:\Users\Administrator\agent-tools\codex-provider-sync.cmd status --codex-home C:\Users\Administrator\.codex
C:\Users\Administrator\agent-tools\codex-provider-sync.cmd sync --keep 5 --codex-home C:\Users\Administrator\.codex
```

## 和 codex-project-sync 的区别

`codex-provider-sync` 解决历史会话可见性：

- rollout files
- SQLite thread metadata
- provider/session visibility
- cwd repair

`codex-project-sync` 解决项目列表恢复：

- project roots
- trust entries
- labels
- project order
- active workspace roots

切换 CC Switch Provider 后，推荐顺序是：

```powershell
C:\Users\Administrator\agent-tools\sync-codex-projects.cmd sync
C:\Users\Administrator\agent-tools\codex-provider-sync.cmd status --codex-home C:\Users\Administrator\.codex
```

只有 `status` 显示需要修复历史会话 metadata 时，再运行 provider sync。

## 安全建议

- 每次写操作前先跑 `status`。
- 不要手动编辑 `state_5.sqlite` 或 rollout jsonl，除非上游 CLI 无法处理。
- 备份目录在 `C:\Users\Administrator\.codex\backups_state\provider-sync`。
- 如果 SQLite 被占用，先关闭 Codex Desktop、Codex CLI、app-server，再重试。
- 如果报告 locked rollout files，被跳过的活跃会话结束后再补跑一次。

## 许可证

本 Skill 包使用 MIT License。上游 CLI 请遵守 [`Dailin521/codex-provider-sync`](https://github.com/Dailin521/codex-provider-sync) 的许可证。

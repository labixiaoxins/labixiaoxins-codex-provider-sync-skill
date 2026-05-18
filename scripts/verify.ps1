param(
  [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }),
  [switch]$SkipStatus
)

$ErrorActionPreference = "Stop"

function Write-Step($Message) {
  Write-Host "[codex-provider-sync-skill] $Message"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillPath = Join-Path $repoRoot "skills\codex-provider-sync"
$pluginJson = Join-Path $repoRoot ".codex-plugin\plugin.json"

if (-not (Test-Path -LiteralPath $skillPath)) {
  throw "Missing skill path: $skillPath"
}
if (-not (Test-Path -LiteralPath $pluginJson)) {
  throw "Missing plugin metadata: $pluginJson"
}

$null = Get-Content -Raw -Encoding UTF8 $pluginJson | ConvertFrom-Json
Write-Step "plugin.json is valid JSON"

$frontmatter = Get-Content -Raw -Encoding UTF8 (Join-Path $skillPath "SKILL.md")
if ($frontmatter -notmatch "(?s)^---\s*\nname:\s*codex-provider-sync\s*\ndescription:\s*.+?\n---") {
  throw "SKILL.md frontmatter is missing required name/description."
}
Write-Step "SKILL.md frontmatter looks valid"

$nodeVersionText = (& node --version).Trim()
$nodeMajor = [int]($nodeVersionText.TrimStart("v").Split(".")[0])
if ($nodeMajor -lt 24) {
  throw "Node.js 24+ is required. Current: $nodeVersionText"
}
Write-Step "Node.js OK: $nodeVersionText"

$provider = Get-Command codex-provider -ErrorAction SilentlyContinue
if (-not $provider) {
  throw "codex-provider CLI not found. Run scripts\install.ps1 first."
}
Write-Step "codex-provider CLI found: $($provider.Source)"

codex-provider --help | Out-String | Write-Host

if (-not $SkipStatus) {
  Write-Step "Running read-only status"
  codex-provider status --codex-home $CodexHome
}

Write-Step "Verification complete"

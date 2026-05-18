param(
  [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }),
  [switch]$SkipNpmInstall
)

$ErrorActionPreference = "Stop"

function Write-Step($Message) {
  Write-Host "[codex-provider-sync-skill] $Message"
}

function Install-SkillCopy($Source, $SkillsRoot, $Label) {
  New-Item -ItemType Directory -Force -Path $SkillsRoot | Out-Null
  $target = Join-Path $SkillsRoot "codex-provider-sync"

  $resolvedRoot = [System.IO.Path]::GetFullPath($SkillsRoot)
  $resolvedTarget = [System.IO.Path]::GetFullPath($target)
  if (-not $resolvedTarget.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to replace target outside skills root: $resolvedTarget"
  }

  if (Test-Path -LiteralPath $target) {
    Remove-Item -Recurse -Force -LiteralPath $target
  }
  Copy-Item -Recurse -Force -LiteralPath $Source -Destination $target
  Write-Step "Installed $Label skill to $target"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillSource = Join-Path $repoRoot "skills\codex-provider-sync"
$wrapperSource = Join-Path $repoRoot "agent-tools\codex-provider-sync.cmd"

if (-not (Test-Path -LiteralPath $skillSource)) {
  throw "Skill source not found: $skillSource"
}

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
  throw "Node.js is required. Install Node.js 24+ first."
}

$nodeVersionText = (& node --version).Trim()
$nodeMajor = [int]($nodeVersionText.TrimStart("v").Split(".")[0])
if ($nodeMajor -lt 24) {
  throw "Node.js 24+ is required because codex-provider-sync uses node:sqlite. Current: $nodeVersionText"
}
Write-Step "Node.js OK: $nodeVersionText"

if (-not $SkipNpmInstall) {
  $npm = Get-Command npm -ErrorAction SilentlyContinue
  if (-not $npm) {
    throw "npm is required to install codex-provider-sync."
  }
  Write-Step "Installing upstream codex-provider-sync CLI"
  npm install -g git+https://github.com/Dailin521/codex-provider-sync.git
}

$codexSkills = Join-Path $CodexHome "skills"
Install-SkillCopy -Source $skillSource -SkillsRoot $codexSkills -Label "Codex"

$sharedSkills = Join-Path $env:USERPROFILE ".agents\skills"
if (Test-Path -LiteralPath (Split-Path -Parent $sharedSkills)) {
  Install-SkillCopy -Source $skillSource -SkillsRoot $sharedSkills -Label "shared agent"
}

$claudeSkills = Join-Path $env:USERPROFILE ".claude\skills"
if (Test-Path -LiteralPath (Split-Path -Parent $claudeSkills)) {
  Install-SkillCopy -Source $skillSource -SkillsRoot $claudeSkills -Label "Claude"
}

$agentTools = Join-Path $env:USERPROFILE "agent-tools"
New-Item -ItemType Directory -Force -Path $agentTools | Out-Null
Copy-Item -Force -LiteralPath $wrapperSource -Destination (Join-Path $agentTools "codex-provider-sync.cmd")
Write-Step "Installed wrapper to $(Join-Path $agentTools 'codex-provider-sync.cmd')"

Write-Step "Install complete. Run scripts\verify.ps1 next."

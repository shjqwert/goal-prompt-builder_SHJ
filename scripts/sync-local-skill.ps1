param(
  [string]$CodexHome = $env:CODEX_HOME
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$source = Join-Path $repoRoot 'goal-prompt-builder'

if ([string]::IsNullOrWhiteSpace($CodexHome)) {
  $CodexHome = Join-Path $HOME '.codex'
}

$dest = Join-Path $CodexHome 'skills\goal-prompt-builder'

if (-not (Test-Path -LiteralPath (Join-Path $source 'SKILL.md'))) {
  throw "Missing source skill: $source"
}

New-Item -ItemType Directory -Path $dest -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $source 'SKILL.md') -Destination (Join-Path $dest 'SKILL.md') -Force
Copy-Item -LiteralPath (Join-Path $source 'references') -Destination $dest -Recurse -Force
Copy-Item -LiteralPath (Join-Path $source 'agents') -Destination $dest -Recurse -Force

$sourceHash = (Get-FileHash -LiteralPath (Join-Path $source 'SKILL.md') -Algorithm SHA256).Hash
$destHash = (Get-FileHash -LiteralPath (Join-Path $dest 'SKILL.md') -Algorithm SHA256).Hash

if ($sourceHash -ne $destHash) {
  throw "Sync failed: SKILL.md hash mismatch"
}

Write-Output "Synced goal-prompt-builder to $dest"

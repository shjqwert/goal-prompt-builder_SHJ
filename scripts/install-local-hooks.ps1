$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$hookDir = Join-Path $repoRoot '.git\hooks'
$syncScript = Join-Path $repoRoot 'scripts\sync-local-skill.ps1'

if (-not (Test-Path -LiteralPath $hookDir)) {
  throw "Missing Git hooks directory: $hookDir"
}

$hookBody = @"
#!/bin/sh
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$syncScript" >/dev/null 2>&1 || true
"@

foreach ($hook in @('post-commit', 'post-merge', 'post-checkout')) {
  $path = Join-Path $hookDir $hook
  Set-Content -LiteralPath $path -Value $hookBody -Encoding ascii
}

Write-Output "Installed local sync hooks in $hookDir"

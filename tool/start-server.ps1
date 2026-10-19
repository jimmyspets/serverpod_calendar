. "$PSScriptRoot/common.ps1"
Assert-Toolchain
Push-Location $WorkspaceRoot
try {
  Invoke-Checked dart @('run', 'tool/setup.dart')
  Invoke-Compose @('up', '-d', '--wait', 'postgres', 'redis')
  & "$PSScriptRoot/build-host.ps1"
  $previousSeed = $env:CALENDAR_EXAMPLE_SEED_DEMO
  $env:CALENDAR_EXAMPLE_SEED_DEMO = 'true'
  Push-Location $ExampleServer
  try {
    $binary = Join-Path $WorkspaceRoot '.local/host/bundle/bin/main'
    if ($IsWindows -or $env:OS -eq 'Windows_NT') { $binary += '.exe' }
    Invoke-Checked $binary @('--mode=development', '--server-id=development', '--apply-migrations')
  } finally {
    Pop-Location
    $env:CALENDAR_EXAMPLE_SEED_DEMO = $previousSeed
  }
} finally { Pop-Location }

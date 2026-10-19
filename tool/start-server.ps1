param([switch]$Interactive)
. "$PSScriptRoot/common.ps1"
Assert-Toolchain
Push-Location $WorkspaceRoot
try {
  Invoke-Checked dart @('run', 'tool/setup.dart')
  Invoke-Compose @('up', '-d', '--wait', 'postgres', 'redis')
  if (-not $Interactive) { & "$PSScriptRoot/build-host.ps1" }
  $previousSeed = $env:CALENDAR_EXAMPLE_SEED_DEMO
  $env:CALENDAR_EXAMPLE_SEED_DEMO = 'true'
  Push-Location $ExampleServer
  try {
    if ($Interactive) {
      # Compose is already configured above. Keep Flutter separate until requested.
      Invoke-Checked serverpod @('--no-analytics', 'start', '--no-docker', '--no-flutter', '--no-tui', '--directory', $ExampleServer, '--', '--mode=development', '--server-id=development')
    } else {
      $binary = Join-Path $WorkspaceRoot '.local/host/bundle/bin/main'
      if ($IsWindows -or $env:OS -eq 'Windows_NT') { $binary += '.exe' }
      Invoke-Checked $binary @('--mode=development', '--server-id=development', '--apply-migrations')
    }
  } finally {
    Pop-Location
    $env:CALENDAR_EXAMPLE_SEED_DEMO = $previousSeed
  }
} finally { Pop-Location }

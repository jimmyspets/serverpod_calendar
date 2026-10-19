param([switch]$SkipBrowser)
. "$PSScriptRoot/common.ps1"
Assert-Toolchain
Push-Location $WorkspaceRoot
try {
  Invoke-Checked flutter @('pub', 'get', '--enforce-lockfile')
  Invoke-Checked dart @('run', 'tool/setup.dart')
  # Re-generation must leave the checked-in protocol/test tools unchanged.
  $generatedRoots = @(
    'packages/serverpod_notifications/serverpod_notifications_server/lib/src/generated',
    'packages/serverpod_notifications/serverpod_notifications_server/test/integration/test_tools',
    'packages/serverpod_notifications/serverpod_notifications_client/lib',
    'packages/serverpod_calendar/serverpod_calendar_server/lib/src/generated',
    'packages/serverpod_calendar/serverpod_calendar_server/test/integration/test_tools',
    'packages/serverpod_calendar/serverpod_calendar_client/lib',
    'example/calendar_example/calendar_example_server/lib/src/generated',
    'example/calendar_example/calendar_example_server/test/integration/test_tools',
    'example/calendar_example/calendar_example_client/lib'
  )
  function Get-GeneratedState {
    $state = @{}
    foreach ($relative in $generatedRoots) {
      Get-ChildItem -LiteralPath (Join-Path $WorkspaceRoot $relative) -Recurse -File | ForEach-Object {
        $state[$_.FullName] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
      }
    }
    return $state
  }
  $before = Get-GeneratedState
  & "$PSScriptRoot/generate.ps1"
  $after = Get-GeneratedState
  if ($before.Count -ne $after.Count) { throw 'Generated file list changed. Review and commit generation output.' }
  foreach ($name in $before.Keys) {
    if ($before[$name] -ne $after[$name]) { throw "Generated output changed: $name" }
  }
  $dartFiles = Get-ChildItem tool,packages,example -Recurse -File -Filter '*.dart' |
    Where-Object { $_.FullName -notmatch '[\\/](\.dart_tool|build|\.serverpod|generated|protocol|test_tools)[\\/]' -and $_.Name -notlike '*_client.dart' } |
    Select-Object -ExpandProperty FullName
  Invoke-Checked dart (@('format', '--output=none', '--set-exit-if-changed') + $dartFiles)
  Invoke-Checked dart @('analyze', '--fatal-infos')
  Push-Location $ExampleFlutter
  try { Invoke-Checked flutter @('test', '--no-pub', 'test/sign_in_test.dart') }
  finally { Pop-Location }
  & "$PSScriptRoot/reset-test.ps1"
  & "$PSScriptRoot/build-host.ps1"
  $smokeArgs = @('run', 'tool/host_smoke.dart')
  if (-not $SkipBrowser) { $smokeArgs += '--flutter' }
  if (-not $SkipBrowser) { & "$PSScriptRoot/setup-webdriver.ps1" }
  Invoke-Checked dart $smokeArgs
  Push-Location $ExampleFlutter
  try { Invoke-Checked flutter @('build', 'web', '--no-pub') }
  finally { Pop-Location }
  Write-Host 'All requested local checks passed.'
} finally { Pop-Location }

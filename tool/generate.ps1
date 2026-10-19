. "$PSScriptRoot/common.ps1"
Assert-Toolchain
foreach ($relative in @(
  'packages/serverpod_notifications/serverpod_notifications_server',
  'packages/serverpod_calendar/serverpod_calendar_server',
  'example/calendar_example/calendar_example_server'
)) {
  Push-Location (Join-Path $WorkspaceRoot $relative)
  try { Invoke-Checked serverpod @('--no-analytics', 'generate') }
  finally { Pop-Location }
}

$ErrorActionPreference = 'Stop'
$WorkspaceRoot = Split-Path $PSScriptRoot -Parent
$ExampleServer = Join-Path $WorkspaceRoot 'example/calendar_example/calendar_example_server'
$ExampleFlutter = Join-Path $WorkspaceRoot 'example/calendar_example/calendar_example_flutter'
function Invoke-Checked {
  param([string]$Command, [Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments = @())
  & $Command @Arguments
  if ($LASTEXITCODE -ne 0) { throw "$Command exited with code $LASTEXITCODE" }
}
function Assert-Toolchain {
  $pins = Get-Content (Join-Path $WorkspaceRoot 'toolchain.json') -Raw | ConvertFrom-Json
  $flutterInfo = (& flutter --version --machine | Out-String) | ConvertFrom-Json
  if ($LASTEXITCODE -ne 0) { throw 'Could not inspect Flutter.' }
  if ($flutterInfo.frameworkVersion -ne $pins.flutter -or $flutterInfo.dartSdkVersion -notlike "$($pins.dart)*") {
    throw "Use Flutter $($pins.flutter) with Dart $($pins.dart); see toolchain.json."
  }
  $serverpodInfo = & serverpod version
  if ($LASTEXITCODE -ne 0 -or $serverpodInfo -notmatch [regex]::Escape($pins.serverpod)) {
    throw "Use Serverpod CLI $($pins.serverpod); see toolchain.json."
  }
}
function Invoke-Compose {
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$ComposeArguments)
  Invoke-Checked docker (@('compose', '--env-file', (Join-Path $WorkspaceRoot '.local/compose.env'), '-f', (Join-Path $ExampleServer 'docker-compose.yaml')) + $ComposeArguments)
}

. "$PSScriptRoot/common.ps1"
Assert-Toolchain
Push-Location $ExampleServer
try { Invoke-Checked dart @('build', 'cli', '--target', 'bin/main.dart', '--output', (Join-Path $WorkspaceRoot '.local/host')) }
finally { Pop-Location }

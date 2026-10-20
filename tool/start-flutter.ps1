. "$PSScriptRoot/common.ps1"
Assert-Toolchain
Push-Location $ExampleFlutter
try { Invoke-Checked flutter @('run', '-d', 'chrome', '--web-hostname', 'localhost', '--web-port', '18083', '--dart-define=API_URL=http://localhost:18080/') }
finally { Pop-Location }

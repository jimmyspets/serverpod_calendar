. "$PSScriptRoot/common.ps1"
$driver = Join-Path $WorkspaceRoot '.local/webdriver/chromedriver-win64/chromedriver.exe'
if ($env:CHROMEDRIVER) {
  if (-not (Test-Path -LiteralPath $env:CHROMEDRIVER)) { throw 'CHROMEDRIVER does not point to a file.' }
  return
}
if (Test-Path -LiteralPath $driver) { return }
if (-not ($IsWindows -or $env:OS -eq 'Windows_NT')) {
  throw 'Install a matching ChromeDriver and set CHROMEDRIVER on this platform.'
}
$chromeCandidates = @(
  (Join-Path $env:ProgramFiles 'Google/Chrome/Application/chrome.exe'),
  (Join-Path ${env:ProgramFiles(x86)} 'Google/Chrome/Application/chrome.exe'),
  (Join-Path $env:LOCALAPPDATA 'Google/Chrome/Application/chrome.exe')
)
$chrome = $chromeCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $chrome) { throw 'Chrome was not found; set CHROMEDRIVER for your installation.' }
$version = (Get-Item -LiteralPath $chrome).VersionInfo.ProductVersion
$buildPrefix = ($version.Split('.')[0..2] -join '.') + '.'
$metadata = Invoke-RestMethod 'https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json'
$release = $metadata.versions | Where-Object version -EQ $version
if (-not $release) { $release = $metadata.versions | Where-Object { $_.version.StartsWith($buildPrefix) } | Select-Object -Last 1 }
$url = ($release.downloads.chromedriver | Where-Object platform -EQ 'win64').url
if (-not $url -or -not $url.StartsWith('https://storage.googleapis.com/chrome-for-testing-public/')) {
  throw "No official ChromeDriver download found for Chrome $version."
}
$folder = Split-Path (Split-Path $driver -Parent) -Parent
New-Item -ItemType Directory -Force $folder | Out-Null
$archive = Join-Path $folder 'chromedriver.zip'
Invoke-WebRequest $url -OutFile $archive
Expand-Archive -LiteralPath $archive -DestinationPath $folder -Force
Invoke-Checked $driver @('--version')

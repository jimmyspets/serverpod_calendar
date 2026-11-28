#!/usr/bin/env bash
# Bootstrap only the disposable GitHub-hosted Linux x64 test environment.
set -euo pipefail
[[ "${GITHUB_ACTIONS:-}" == true && "$(uname -s)" == Linux && "$(uname -m)" == x86_64 ]] || {
  echo 'This bootstrap requires a GitHub Actions Linux x64 runner.' >&2
  exit 1
}
: "${RUNNER_TEMP:?}" "${GITHUB_PATH:?}" "${GITHUB_ENV:?}"
version="$(jq -er '.flutter' toolchain.json)"
checksum="$(jq -er '.ci.flutterLinuxX64Sha256' toolchain.json)"
serverpod="$(jq -er '.serverpod' toolchain.json)"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && "$checksum" =~ ^[a-f0-9]{64}$ && "$serverpod" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
sdk_root="$RUNNER_TEMP/calendar-flutter-$version"
mkdir "$sdk_root"
archive="$sdk_root/sdk.tar.xz"
curl --fail --location --retry 3 --proto '=https' --proto-redir '=https' \
  "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${version}-stable.tar.xz" \
  --output "$archive"
printf '%s  %s\n' "$checksum" "$archive" | sha256sum --check --status
tar -xJf "$archive" -C "$sdk_root"
rm -- "$archive"
export PATH="$sdk_root/flutter/bin:$PATH"
export PUB_CACHE="$RUNNER_TEMP/calendar-pub-cache"
printf '%s\n' "$sdk_root/flutter/bin" "$PUB_CACHE/bin" >> "$GITHUB_PATH"
printf 'PUB_CACHE=%s\n' "$PUB_CACHE" >> "$GITHUB_ENV"
flutter config --enable-web --no-analytics
dart --disable-analytics
dart pub global activate serverpod_cli "$serverpod"
export PATH="$PUB_CACHE/bin:$PATH"
serverpod --no-analytics version

real_chrome="$(command -v google-chrome)"
driver="${CHROMEWEBDRIVER:+$CHROMEWEBDRIVER/chromedriver}"
if [[ -z "$driver" ]]; then driver="$(command -v chromedriver)"; fi
[[ -x "$real_chrome" && -x "$driver" ]]
chrome_version="$("$real_chrome" --version | grep -oE '[0-9]+(\.[0-9]+){3}' | head -n 1)"
driver_version="$("$driver" --version | grep -oE '[0-9]+(\.[0-9]+){3}' | head -n 1)"
[[ "${chrome_version%.*}" == "${driver_version%.*}" ]] || {
  echo "Chrome/driver build mismatch: $chrome_version / $driver_version" >&2
  exit 1
}
cat > "$sdk_root/chrome-ci" <<'CHROME'
#!/usr/bin/env bash
exec "$CI_REAL_CHROME" --no-sandbox "$@"
CHROME
chmod u+x "$sdk_root/chrome-ci"
printf 'CI_REAL_CHROME=%s\nCHROME_EXECUTABLE=%s\nCHROMEDRIVER=%s\n' \
  "$real_chrome" "$sdk_root/chrome-ci" "$driver" >> "$GITHUB_ENV"
printf 'CI browser: Chrome %s; ChromeDriver %s\n' "$chrome_version" "$driver_version"

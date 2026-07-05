#!/bin/sh
set -eu

plugin_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
release_file="$plugin_root/config/runner-release.json"

json_value() {
    sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$release_file"
}

repository=$(json_value repository)
version=$(json_value version)
os=$(uname -s)
arch=$(uname -m)

case "$os:$arch" in
    Linux:x86_64) key=linux-x86_64 ;;
    Darwin:x86_64) key=macos-x86_64 ;;
    Darwin:arm64) key=macos-aarch64 ;;
    *) echo "Unsupported platform: $os/$arch" >&2; exit 2 ;;
esac

asset=$(json_value "$key")
[ -n "$asset" ] || { echo "No runner release asset for $key" >&2; exit 2; }

tag="v$version"
base_url="https://github.com/$repository/releases/download/$tag"
cache_root=${XDG_CACHE_HOME:-"$HOME/.cache"}
version_root="$cache_root/unity-testing/runner/$tag"
bin_dir="$version_root/bin"
runner="$bin_dir/unity-test-runner"
config_dir="$version_root/config"

mkdir -p "$bin_dir" "$config_dir"
cp "$plugin_root/config/default.toml" "$config_dir/default.toml"

if [ ! -f "$runner" ]; then
    download="$runner.$$.download"
    checksum_download="$download.sha256"
    trap 'rm -f "$download" "$checksum_download"' EXIT INT TERM

    curl -fsSL "$base_url/$asset" -o "$download"
    curl -fsSL "$base_url/$asset.sha256" -o "$checksum_download"
    expected=$(awk '{print $1; exit}' "$checksum_download")
    if command -v sha256sum >/dev/null 2>&1; then
        actual=$(sha256sum "$download" | awk '{print $1}')
    else
        actual=$(shasum -a 256 "$download" | awk '{print $1}')
    fi
    [ "$actual" = "$expected" ] || { echo "SHA-256 mismatch for $asset" >&2; exit 2; }

    mv "$download" "$runner"
    chmod +x "$runner"
    rm -f "$checksum_download"
    trap - EXIT INT TERM
fi

exec "$runner" "$@"

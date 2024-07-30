# https://nyc3.digitaloceanspaces.com/zed-nightly-host/nightly/Zed-aarch64.dmg

platform="$(uname -s)"
arch="$(uname -m)"
temp="$(mktemp -d "/tmp/zed-XXXXXX")"
curl "https://zed.dev/api/releases/nightly/latest/Zed-$arch.dmg" > "$temp/Zed-$arch.dmg"
hdiutil attach -quiet "$temp/Zed-$arch.dmg" -mountpoint "$temp/mount"
app="$(cd "$temp/mount/"; echo *.app)"
echo "Installing $app"
if [ -d "/Applications/$app" ]; then
    echo "Removing existing $app"
    rm -rf "/Applications/$app"
fi
ditto "$temp/mount/$app" "/Applications/$app"
hdiutil detach -quiet "$temp/mount"

mkdir -p "$HOME/.local/bin"
# Link the binary
ln -sf "/Applications/$app/Contents/MacOS/cli" "$HOME/.local/bin/zed"

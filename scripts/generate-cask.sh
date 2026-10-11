#!/bin/bash
# Prints the Homebrew cask for a release to stdout.
# Usage: scripts/generate-cask.sh <version> <zip-sha256>
set -euo pipefail

VERSION="$1"; SHA="$2"
REPO="${GITHUB_REPOSITORY:-lucabartmann/MouseTune}"

cat <<RUBY
cask "mousetune" do
  version "$VERSION"
  sha256 "$SHA"

  url "https://github.com/$REPO/releases/download/v#{version}/MouseTune-#{version}.zip"
  name "MouseTune"
  desc "Menu bar app to tune mouse pointer speed, scrolling and buttons"
  homepage "https://github.com/$REPO"

  depends_on macos: ">= :ventura"

  app "MouseTune.app"
RUBY

cat <<'RUBY'

  # Release builds are not notarized; clear the quarantine flag so Gatekeeper doesn't block them.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/MouseTune.app"]
  end
RUBY

cat <<'RUBY'

  zap trash: "~/Library/Preferences/local.MouseTune.plist"

  caveats <<~EOS
    MouseTune needs the Accessibility permission:
      System Settings → Privacy & Security → Accessibility
  EOS
end
RUBY

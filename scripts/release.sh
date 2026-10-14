#!/opt/homebrew/bin/bash
# Build, sign (Developer ID), notarize and staple TimeScroll+, producing dist/TimeScroll+-<tag>.zip.
# Publishing the GitHub release is a separate, explicit step (printed at the end).
#
# Requirements:
#   - "Developer ID Application" certificate for team HSQBCXXYLQ in the login keychain
#   - notarytool credentials stored as keychain profile "timescroll-notary"
#
# Usage: scripts/release.sh            (tag derived from the project: v<marketing>-plus.<fork build>)
set -euo pipefail

TEAM_ID=HSQBCXXYLQ
NOTARY_PROFILE=timescroll-notary
ROOT=$(cd "$(dirname "$0")/.." && pwd)
PROJECT="$ROOT/app/TimeScroll.xcodeproj"
WORK="$ROOT/dist/work"
APP_NAME="TimeScroll+"

cd "$ROOT"
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is not clean; commit first so the release matches a tag." >&2
  exit 1
fi

settings=$(xcodebuild -project "$PROJECT" -scheme TimeScroll -configuration Release -showBuildSettings 2>/dev/null)
marketing=$(awk -F' = ' '/ MARKETING_VERSION = /{print $2; exit}' <<<"$settings")
build=$(awk -F' = ' '/ CURRENT_PROJECT_VERSION = /{print $2; exit}' <<<"$settings")
fork_build=${build#*.}                 # 48.1 -> 1
TAG="v${marketing}-plus.${fork_build}"
ZIP="$ROOT/dist/${APP_NAME}-${TAG}.zip"
echo "==> Releasing $APP_NAME $marketing ($build) as $TAG"

rm -rf "$WORK" && mkdir -p "$WORK"

echo "==> Archiving"
xcodebuild -project "$PROJECT" -scheme TimeScroll -configuration Release \
  -archivePath "$WORK/TimeScroll.xcarchive" -derivedDataPath "$WORK/dd" \
  CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM="$TEAM_ID" CODE_SIGN_IDENTITY="Developer ID Application" \
  PROVISIONING_PROFILE_SPECIFIER= OTHER_CODE_SIGN_FLAGS=--timestamp \
  archive 2>&1 | grep -E 'error:|\*\* ARCHIVE'

cat > "$WORK/ExportOptions.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>developer-id</string>
  <key>signingStyle</key><string>manual</string>
  <key>signingCertificate</key><string>Developer ID Application</string>
  <key>teamID</key><string>${TEAM_ID}</string>
</dict>
</plist>
EOF

echo "==> Exporting (re-signs all nested code with Developer ID)"
xcodebuild -exportArchive -archivePath "$WORK/TimeScroll.xcarchive" \
  -exportOptionsPlist "$WORK/ExportOptions.plist" -exportPath "$WORK/export" 2>&1 \
  | grep -E 'error:|\*\* EXPORT'
APP="$WORK/export/${APP_NAME}.app"

echo "==> Verifying signature"
codesign --verify --deep --strict --verbose=2 "$APP" 2>&1 | tail -2
codesign -dvv "$APP" 2>&1 | grep -E '^Authority=Developer ID Application|^TeamIdentifier|^Identifier'

echo "==> Notarizing"
ditto -c -k --keepParent "$APP" "$WORK/notarize.zip"
xcrun notarytool submit "$WORK/notarize.zip" --keychain-profile "$NOTARY_PROFILE" --wait

echo "==> Stapling"
xcrun stapler staple "$APP"
spctl --assess --type execute --verbose=2 "$APP"

ditto -c -k --keepParent "$APP" "$ZIP"
shasum -a 256 "$ZIP"
echo
echo "Built $ZIP"
echo "Publish with:"
echo "  git tag $TAG && git push origin $TAG"
echo "  gh release create $TAG '$ZIP' --repo paidem/TimeScrollApp --title '$APP_NAME $marketing (fork build $fork_build)' --notes-file <notes.md>"

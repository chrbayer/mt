#!/usr/bin/env bash
# Build the Mathe-Trainer Linux desktop app.
#
# The tablet is the real target; the Linux build exists so the app can be
# iterated on quickly at the desktop.
#
# Usage:
#   ./build_client.sh          # release build → build/linux/x64/release/bundle/
#   ./build_client.sh --debug  # debug build   → build/linux/x64/debug/bundle/
#   ./build_client.sh --run    # build, then start the app

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

DEBUG=false
RUN=false
for arg in "$@"; do
    case "$arg" in
        --debug) DEBUG=true ;;
        --run)   RUN=true ;;
        *) echo "Unknown option: $arg" >&2; exit 2 ;;
    esac
done

# A pubspec version may be "1.0.0" or "1.0.0+7". Flutter wants the two halves
# separately - passing the whole string as --build-name would put the "+7"
# inside the Android versionName.
PUBSPEC_VERSION=$(grep '^version:' "$DIR/pubspec.yaml" | sed 's/version: //' | tr -d '[:space:]')
BUILD_NAME="${PUBSPEC_VERSION%%+*}"

# Without a "+N" Flutter would give every build versionCode 1, and that is
# what Android goes by when it decides whether an APK is an upgrade. Two
# different builds both claiming 1 are not an upgrade to the package manager,
# and installing one over the other can leave the app in a half-replaced
# state that does not start. So the code is derived from the version instead:
# 2.4.1 becomes 20401, and every release really is newer than the last.
if [[ "$PUBSPEC_VERSION" == *+* ]]; then
    BUILD_NUMBER="${PUBSPEC_VERSION##*+}"
else
    IFS=. read -r MAJOR MINOR PATCH <<< "$BUILD_NAME"
    BUILD_NUMBER=$(( ${MAJOR:-0} * 10000 + ${MINOR:-0} * 100 + ${PATCH:-0} ))
fi

# The version also goes in as a compile-time constant, so the app can print
# it on its start screen. --build-name alone only reaches the Android
# manifest, which the Dart side cannot read without a plugin.
VERSION_ARGS=(
    --build-name="$BUILD_NAME"
    --build-number="$BUILD_NUMBER"
    --dart-define=MT_VERSION="$BUILD_NAME"
)
echo "Version: $BUILD_NAME (versionCode $BUILD_NUMBER)"

if $DEBUG; then
    echo "Building Linux DEBUG…"
    flutter build linux --debug "${VERSION_ARGS[@]}"
    BUNDLE="$DIR/build/linux/x64/debug/bundle"
else
    echo "Building Linux RELEASE…"
    flutter build linux --release "${VERSION_ARGS[@]}"
    BUNDLE="$DIR/build/linux/x64/release/bundle"
fi

echo "Done: $BUNDLE/"

if $RUN; then
    exec "$BUNDLE/mathe_trainer"
fi

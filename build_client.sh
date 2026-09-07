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
# inside the Android versionName. Without a "+N" no build number is passed and
# Flutter defaults the Android versionCode to 1.
PUBSPEC_VERSION=$(grep '^version:' "$DIR/pubspec.yaml" | sed 's/version: //' | tr -d '[:space:]')
BUILD_NAME="${PUBSPEC_VERSION%%+*}"
# The version also goes in as a compile-time constant, so the app can print
# it on its start screen. --build-name alone only reaches the Android
# manifest, which the Dart side cannot read without a plugin.
VERSION_ARGS=(--build-name="$BUILD_NAME" --dart-define=MT_VERSION="$BUILD_NAME")
if [[ "$PUBSPEC_VERSION" == *+* ]]; then
    BUILD_NUMBER="${PUBSPEC_VERSION##*+}"
    VERSION_ARGS+=(--build-number="$BUILD_NUMBER")
    echo "Version: $BUILD_NAME (Build $BUILD_NUMBER)"
else
    echo "Version: $BUILD_NAME"
fi

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

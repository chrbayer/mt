#!/usr/bin/env bash
# Build the Mathe-Trainer Android APK and publish it to the web server.
#
# Usage:
#   ./build_android.sh            # release → build/app/outputs/flutter-apk/mt-<version>.apk
#   ./build_android.sh --debug    # debug   → …/mt-<version>-debug.apk
#   ./build_android.sh --no-upload
#
# The APK carries the build name from pubspec.yaml, so a file lying around on
# a tablet still says which version it is.
#
# Signing (release only) — configure via env vars:
#   MT_KEYSTORE_PATH     path to .keystore / .jks file
#   MT_KEYSTORE_ALIAS    key alias inside the keystore (default: mathetrainer)
#   MT_KEYSTORE_PASS     keystore + key password
#
# If MT_KEYSTORE_PATH is unset the APK is signed with the debug keystore.
#
# Deployment (override to publish elsewhere):
#   MT_DEPLOY_HOST       default criby.de
#   MT_DEPLOY_USER       default chrbayer
#   MT_DEPLOY_DIR        directory under the web root and APK base name,
#                        default mt
#   MT_DEPLOY_ROOT       default /srv/http/main_ssl

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

DEBUG=false
UPLOAD=true
for arg in "$@"; do
    case "$arg" in
        --debug)     DEBUG=true ;;
        --no-upload) UPLOAD=false ;;
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

# Write key.properties for release signing if env vars are set
KEY_PROPS="$DIR/android/key.properties"
if ! $DEBUG && [[ -n "${MT_KEYSTORE_PATH:-}" ]]; then
    cat > "$KEY_PROPS" << PROPS
storePassword=${MT_KEYSTORE_PASS:-}
keyPassword=${MT_KEYSTORE_PASS:-}
keyAlias=${MT_KEYSTORE_ALIAS:-mathetrainer}
storeFile=${MT_KEYSTORE_PATH}
PROPS
    trap 'rm -f "$KEY_PROPS"' EXIT
fi

# Where the APK goes, and under which name. The deploy directory doubles as the
# base name, so the local file and the uploaded one are called the same thing.
DEPLOY_HOST="${MT_DEPLOY_HOST:-criby.de}"
DEPLOY_USER="${MT_DEPLOY_USER:-chrbayer}"
DEPLOY_DIR="${MT_DEPLOY_DIR:-mt}"
DEPLOY_ROOT="${MT_DEPLOY_ROOT:-/srv/http/main_ssl}"

if $DEBUG; then
    echo "Building Android DEBUG APK…"
    flutter build apk --debug "${VERSION_ARGS[@]}"
    BUILT="$DIR/build/app/outputs/flutter-apk/app-debug.apk"
    APK_NAME="$DEPLOY_DIR-$BUILD_NAME-debug.apk"
else
    echo "Building Android RELEASE APK…"
    flutter build apk --release "${VERSION_ARGS[@]}"
    BUILT="$DIR/build/app/outputs/flutter-apk/app-release.apk"
    APK_NAME="$DEPLOY_DIR-$BUILD_NAME.apk"
fi

# Flutter always writes app-release.apk. Copying it to a versioned name means a
# downloaded file still says which build it is, months later on some tablet.
OUT="$DIR/build/app/outputs/flutter-apk/$APK_NAME"
cp -f "$BUILT" "$OUT"

echo "Done: $OUT"

if ! $UPLOAD; then
    exit 0
fi

# Upload the APK under the same versioned name it has locally. There is no web
# version of this app - the directory only serves the APK for download.
DEPLOY_PATH="$DEPLOY_ROOT/$DEPLOY_DIR"

echo "Uploading $APK_NAME to $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/ …"
rsync -av "$OUT" "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/$APK_NAME"
echo "Available at https://$DEPLOY_HOST/$DEPLOY_DIR/$APK_NAME"

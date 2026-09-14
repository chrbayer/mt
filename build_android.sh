#!/usr/bin/env bash
# Build the Mathe-Trainer Android APK and publish it.
#
# Usage:
#   ./build_android.sh              # release → build/app/outputs/flutter-apk/mt-<version>.apk,
#                                   #           uploaded to the web server
#   ./build_android.sh --debug      # debug   → …/mt-<version>-debug.apk
#   ./build_android.sh --no-upload  # build only, nothing goes to the web server
#   ./build_android.sh --github     # additionally one APK per ABI, and all of them
#                                   # published as the GitHub release v<version>
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
# --github refuses to run that way.
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
GITHUB=false
for arg in "$@"; do
    case "$arg" in
        --debug)     DEBUG=true ;;
        --no-upload) UPLOAD=false ;;
        --github)    GITHUB=true ;;
        *) echo "Unknown option: $arg" >&2; exit 2 ;;
    esac
done

fail() { echo "FEHLER: $*" >&2; exit 1; }

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

# F-Droid builds with exactly the Flutter named in .flutter-version. A local
# build with a different one is not wrong, but it is not the build users get
# from there either - say so instead of letting the two drift apart quietly.
WANT_FLUTTER=$(tr -d '[:space:]' < "$DIR/.flutter-version")
HAVE_FLUTTER=$(flutter --version --machine 2>/dev/null | sed -n 's/.*"frameworkVersion": *"\([^"]*\)".*/\1/p')
if [[ -n "$WANT_FLUTTER" && "$HAVE_FLUTTER" != "$WANT_FLUTTER" ]]; then
    # For the GitHub release it is not a warning. F-Droid rebuilds these APKs
    # from source and only accepts them if every byte matches; with another
    # Flutter that cannot happen, and the release would be useless.
    $GITHUB && fail "Flutter $HAVE_FLUTTER installiert, .flutter-version nennt $WANT_FLUTTER."
    echo "WARNUNG: Flutter $HAVE_FLUTTER installiert, .flutter-version nennt $WANT_FLUTTER." >&2
fi

TAG="v$BUILD_NAME"
if $GITHUB; then
    # Everything is checked before the first build: finding out after ten
    # minutes of Gradle that the tag is missing helps nobody.
    $DEBUG && fail "--github baut Release-APKs und passt nicht zu --debug."
    [[ -n "${MT_KEYSTORE_PATH:-}" && -n "${MT_KEYSTORE_PASS:-}" ]] \
        || fail "MT_KEYSTORE_PATH und MT_KEYSTORE_PASS müssen gesetzt sein. Ein debug-signiertes Release nimmt F-Droid nicht an."
    [[ -f "$MT_KEYSTORE_PATH" ]] || fail "Keystore nicht gefunden: $MT_KEYSTORE_PATH"
    command -v gh >/dev/null || fail "gh (GitHub CLI) ist nicht installiert."

    # F-Droid builds the tagged commit. An APK built from anything else - a
    # later commit, an uncommitted change - would never match its build.
    [[ -z "$(git -C "$DIR" status --porcelain --untracked-files=no)" ]] \
        || fail "Es gibt nicht committete Änderungen. Das Release muss genau aus $TAG gebaut werden."
    TAG_COMMIT=$(git -C "$DIR" rev-parse -q --verify "$TAG^{commit}" || true)
    [[ -n "$TAG_COMMIT" ]] || fail "Den Tag $TAG gibt es nicht."
    [[ "$(git -C "$DIR" rev-parse HEAD)" == "$TAG_COMMIT" ]] \
        || fail "HEAD ist nicht $TAG. Erst 'git checkout $TAG' oder den Tag auf den richtigen Commit setzen."
    git -C "$DIR" ls-remote --exit-code --tags origin "refs/tags/$TAG" >/dev/null \
        || fail "$TAG ist noch nicht auf GitHub. Erst 'git push origin $TAG'."
fi

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
APK_DIR="$DIR/build/app/outputs/flutter-apk"

if $DEBUG; then
    echo "Building Android DEBUG APK…"
    flutter build apk --debug "${VERSION_ARGS[@]}"
    BUILT="$APK_DIR/app-debug.apk"
    APK_NAME="$DEPLOY_DIR-$BUILD_NAME-debug.apk"
else
    echo "Building Android RELEASE APK…"
    flutter build apk --release "${VERSION_ARGS[@]}"
    BUILT="$APK_DIR/app-release.apk"
    APK_NAME="$DEPLOY_DIR-$BUILD_NAME.apk"
fi

# Flutter always writes app-release.apk. Copying it to a versioned name means a
# downloaded file still says which build it is, months later on some tablet.
OUT="$APK_DIR/$APK_NAME"
cp -f "$BUILT" "$OUT"

echo "Done: $OUT"

if $UPLOAD; then
    # Upload the APK under the same versioned name it has locally. There is no
    # web version of this app - the directory only serves the APK for download.
    DEPLOY_PATH="$DEPLOY_ROOT/$DEPLOY_DIR"

    echo "Uploading $APK_NAME to $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/ …"
    rsync -av "$OUT" "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/$APK_NAME"
    echo "Available at https://$DEPLOY_HOST/$DEPLOY_DIR/$APK_NAME"
fi

if ! $GITHUB; then
    exit 0
fi

# One APK per ABI, built exactly the way the F-Droid recipe builds them: the
# same arguments, no --build-name or --build-number (pubspec.yaml carries
# both), and the pub cache inside the project, as F-Droid keeps it there for
# its scanner. Any difference here is a byte that F-Droid's build will not
# reproduce, and then it rejects the signature it was meant to copy.
echo "Building one APK per ABI for GitHub…"
echo "Build-Pfad: $DIR (die F-Droid-Recipe muss denselben benutzen)"
export PUB_CACHE="$DIR/.pub-cache"
(cd "$DIR" && flutter pub get --enforce-lockfile)

ASSETS=("$OUT")
for pair in armeabi-v7a:android-arm arm64-v8a:android-arm64 x86_64:android-x64; do
    abi="${pair%%:*}"
    platform="${pair##*:}"
    echo "Building $abi…"
    (cd "$DIR" && flutter build apk --release --split-per-abi \
        --target-platform="$platform" --dart-define=MT_VERSION="$BUILD_NAME")
    asset="$APK_DIR/$DEPLOY_DIR-$BUILD_NAME-$abi.apk"
    cp -f "$APK_DIR/app-$abi-release.apk" "$asset"
    ASSETS+=("$asset")
done

# A release signed with the debug key would be published for good before
# anyone noticed. apksigner says which key it was; without it, say that the
# check did not happen rather than pretend it passed.
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
APKSIGNER=$(find "$SDK/build-tools" -mindepth 2 -maxdepth 2 -name apksigner -type f 2>/dev/null | sort -V | tail -1 || true)
if [[ -n "$APKSIGNER" ]]; then
    for asset in "${ASSETS[@]}"; do
        signer=$("$APKSIGNER" verify --print-certs "$asset" | sed -n 's/.*certificate DN: //p' | head -1)
        [[ "$signer" != *"Android Debug"* ]] || fail "$(basename "$asset") ist mit dem Debug-Schlüssel signiert."
        echo "$(basename "$asset"): $signer"
    done
else
    echo "WARNUNG: apksigner nicht gefunden, die Signatur wurde nicht geprüft." >&2
fi

cd "$DIR"
NOTES="$DIR/fastlane/metadata/android/de-DE/changelogs/$BUILD_NUMBER.txt"
if gh release view "$TAG" >/dev/null 2>&1; then
    echo "Release $TAG gibt es schon, es kommen nur die APKs dazu."
else
    if [[ -f "$NOTES" ]]; then
        NOTES_ARGS=(--notes-file "$NOTES")
    else
        NOTES_ARGS=(--notes "Mathe-Trainer $BUILD_NAME")
    fi
    gh release create "$TAG" --verify-tag --title "Mathe-Trainer $BUILD_NAME" "${NOTES_ARGS[@]}"
fi

# Deliberately no --clobber. F-Droid copies the signature from these exact
# files; replacing one after F-Droid has checked it would publish a binary
# nobody compared. If an upload has to be redone, delete the asset by hand.
gh release upload "$TAG" "${ASSETS[@]}"

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo
echo "Release: https://github.com/$REPO/releases/tag/$TAG"
echo "Für die F-Droid-Recipe (binary je Block):"
echo "  https://github.com/$REPO/releases/download/v%v/$DEPLOY_DIR-%v-<abi>.apk"

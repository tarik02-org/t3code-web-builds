#!/usr/bin/env bash
# Builds upstream's web app at TAG as a hosted static app and writes
# OUTPUT_DIR/T3-Code-Web-<version>.zip, with the app under dist/.
set -euo pipefail

tag="$1"
output_dir="$(realpath -m "$2")"
version="${tag#v}"

# The web app only skips the "primary environment" (the server that served it) when it is
# built with a hosted channel; upstream's own hosted build uses these two names.
case "$version" in
  *-nightly.*) hosted_channel="nightly" ;;
  *) hosted_channel="latest" ;;
esac

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

git clone --quiet --depth 1 --branch "$tag" https://github.com/pingdotgg/t3code.git "$work/src"
cd "$work/src"

export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
corepack pnpm install --frozen-lockfile --ignore-scripts \
  --filter=@t3tools/scripts... --filter=@t3tools/web...
node scripts/update-release-package-versions.ts "$version"

T3CODE_CLERK_PUBLISHABLE_KEY="" \
  T3CODE_CLERK_JWT_TEMPLATE="" \
  T3CODE_RELAY_URL="" \
  APP_VERSION="$version" \
  VITE_HOSTED_APP_CHANNEL="$hosted_channel" \
  corepack pnpm --filter @t3tools/web exec vp build

index="apps/web/dist/index.html"
if grep -Eq '(src|href)="assets/' "$index" || ! grep -Eq '(src|href)="/assets/' "$index"; then
  echo "web assets must use root-relative paths" >&2
  exit 1
fi

mkdir -p "$output_dir"
archive="$output_dir/T3-Code-Web-$version.zip"
rm -f "$archive"
(cd apps/web && zip -qr "$archive" dist -x 'dist/**/*.map')
unzip -tq "$archive"
echo "$archive"

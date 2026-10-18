#!/usr/bin/env bash
# Prints the newest published upstream tag for a channel (stable or nightly).
set -euo pipefail

channel="$1"
upstream="pingdotgg/t3code"

case "$channel" in
  stable) filter='.prerelease == false' ;;
  # Preview and canary prereleases are maintainer test builds; only nightlies are a channel.
  nightly) filter='.prerelease == true and (.tag_name | test("^v[0-9]+\\.[0-9]+\\.[0-9]+-nightly\\.[0-9]{8}\\.[0-9]+$"))' ;;
  *)
    echo "unknown channel: $channel" >&2
    exit 1
    ;;
esac

tag="$(
  gh api "repos/$upstream/releases?per_page=100" \
    --jq "[.[] | select(.draft == false) | select($filter)][0].tag_name // empty"
)"
if [[ -z "$tag" ]]; then
  echo "no published $channel release in the newest 100 upstream releases" >&2
  exit 1
fi
printf '%s\n' "$tag"

#!/bin/sh
# Prints the versions.map entry for an IYAKKI version, as five lines: ffmpeg version, source sha256, builder image, sonames (comma separated), and the matching map pattern.
#   tools/map-lookup.sh 0.1.0-alpha.1 [versions.map]
# Exit 1 and a message on stderr when no entry matches (the version has no build route: use a mirror or a file).
set -eu
V="${1:?IYAKKI version}"; MAP="${2:-$(dirname "$0")/../versions.map}"
grep -v '^[[:space:]]*#' "$MAP" | grep -v '^[[:space:]]*$' | while read -r pat ff sha img so rest; do
  case "$V" in
    $pat) [ -z "${rest:-}" ] || { echo "versions.map: too many fields on the line for $pat" >&2; exit 2; }
          printf '%s\n%s\n%s\n%s\n%s\n' "$ff" "$sha" "$img" "$so" "$pat"; exit 0 ;;
  esac
done | { l=$(cat); [ -n "$l" ] && printf '%s\n' "$l" || { echo "no versions.map entry for IYAKKI $V (it has no build route; use a mirror or a package file)" >&2; exit 1; }; }

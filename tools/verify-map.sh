#!/bin/sh
# Checks versions.map: five fields per line, a 64-hex source hash, a builder image pinned by digest, and the six sonames. With --online it also
# downloads each source and compares its hash (this is how a dead source is found before an entry is removed).
set -eu
MAP="$(dirname "$0")/../versions.map"; bad=0
while read -r pat ff sha img so rest; do
  [ -n "${rest:-}" ] && { echo "too many fields: $pat" >&2; bad=1; continue; }
  printf '%s' "$sha" | grep -Eq '^[0-9a-f]{64}$' || { echo "$pat: the source hash is not 64 hex digits" >&2; bad=1; }
  printf '%s' "$img" | grep -Eq '@sha256:[0-9a-f]{64}$' || { echo "$pat: the builder image is not pinned by digest" >&2; bad=1; }
  [ "$(printf "%s" "$so" | awk -F, "{print NF}")" -ge 6 ] || { echo "$pat: fewer than six sonames" >&2; bad=1; }
  if [ "${1:-}" = "--online" ]; then
    got="$(curl -fsSL --proto '=https' "https://ffmpeg.org/releases/ffmpeg-$ff.tar.xz" | sha256sum | cut -d' ' -f1)" || got=""
    [ "$got" = "$sha" ] || { echo "$pat: ffmpeg-$ff.tar.xz is gone or its hash differs ($got)" >&2; bad=1; }
  fi
done <<EOM
$(grep -v '^[[:space:]]*#' "$MAP" | grep -v '^[[:space:]]*$')
EOM
[ "$bad" = 0 ] && echo "versions.map ok"
exit "$bad"

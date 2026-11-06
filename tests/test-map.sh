#!/bin/sh
# Tests for tools/map-lookup.sh and tools/verify-map.sh (offline).
set -eu
H="$(cd "$(dirname "$0")/.." && pwd)"; fail=0
t() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: expected '$2', got '$3'" >&2; fail=1; fi; }
t "alpha matches the wildcard entry" "6.1.5" "$("$H/tools/map-lookup.sh" 0.1.0-alpha.7 | sed -n 1p)"
t "the digest is returned" "yes" "$("$H/tools/map-lookup.sh" 0.1.0-alpha.1 | sed -n 3p | grep -q '@sha256:' && echo yes)"
t "an unknown version has no route" "1" "$("$H/tools/map-lookup.sh" 9.9.9 >/dev/null 2>&1 && echo 0 || echo $?)"
t "the shipped map verifies" "versions.map ok" "$("$H/tools/verify-map.sh")"
tmp="$(mktemp)"; printf '0.1.0  6.1.5  nothex  alpine:3  a,b\n' > "$tmp"
t "a bad hash is refused" "1" "$(sed "s|MAP=.*; bad=0|MAP=$tmp; bad=0|" "$H/tools/verify-map.sh" | sh >/dev/null 2>&1 && echo 0 || echo $?)"
rm -f "$tmp"
exit "$fail"

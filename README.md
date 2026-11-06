# iyakki-media-bridge

The audio and video add-on of the IYAKKI browser (H.264, AAC and MP3 playback), built on your own machine.

IYAKKI ships and hosts **no FFmpeg**. The IYAKKI image carries only the inactive GStreamer bridge plugin (LGPL glue code). This repository holds
what is needed to build the six FFmpeg shared libraries that plugin loads, from FFmpeg's own source, LGPL only, inside an isolated build container
on the device (k3s) after the person has read the consent text and pressed Build.

* `versions.map` — for every IYAKKI version, which FFmpeg version to build, the SHA-256 of its source tarball, the builder container (pinned by digest) and the
  library names (sonames) the plugin needs. An entry is removed when its source or builder image is no longer available; `CHANGELOG.md` announces that first.
  A version without an entry has no build route: use an administrator mirror or a package file.
* `recipe/build.sh` — runs inside the build container: downloads the source, **refuses it if the hash differs**, configures LGPL-only (`recipe/configure-args.txt`,
  no GPL, no non-free, no encoders), builds, checks the result (sonames, dependencies: only musl's libc and zlib) and writes
  `ffmpeg-libs-<version>-linux-musl-<arch>.tar.gz` with its licence texts, NOTICE and source offer. The archive is reproducible (fixed order and times).
* `tools/map-lookup.sh` — the entry for an IYAKKI version; `tools/verify-map.sh [--online]` — checks the map (and, online, that every source still exists with the same hash).
* `tests/test-map.sh` — offline tests of the two tools.

## Try the recipe by hand

```
. <(tools/map-lookup.sh 0.1.0-alpha.1 | { read ff; read sha; read img; read so; read pat; echo "FF=$ff SHA=$sha IMG=$img SO=$so"; })
mkdir -p out work
docker run --rm -v "$PWD/recipe:/recipe:ro" -v "$PWD/out:/out" -v "$PWD/work:/work" -e WORK=/work -e OUT=/out "$IMG" sh /recipe/build.sh "$FF" "$SHA" "$SO"
```

It takes a few minutes. The package lands in `out/`; copy it to `/local/packages/` on the IYAKKI device (Store → Setup → Browser audio and video reads it).

## Licences

* Our files (the recipe, the map, the tools): Apache-2.0 (`LICENSE`).
* FFmpeg (downloaded, not included): LGPL-2.1+. The built libraries are shared, so you can replace them with your own build of the same version.
* H.264 and AAC are patent-licensed formats in some countries. Building and using these libraries is your choice and your responsibility; this is not legal advice.

## Status

First version. The map has one entry (IYAKKI 0.1.0-alpha.* → FFmpeg 6.1.5). The container recipe was run and its output checked with `iyakki-av-check`; loading it in the
IYAKKI browser engine is verified by IYAKKI's `qemu-av-addon-test.py`.

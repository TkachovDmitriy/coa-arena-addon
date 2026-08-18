#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
addon_dir="$repo_root/TDArenaLens"
manifest="$addon_dir/TDArenaLens.toc"
dist_dir="$repo_root/dist"

if ! command -v zip >/dev/null 2>&1; then
   echo "error: zip is required to package the addon" >&2
   exit 1
fi

version="$(sed -n 's/^## Version: *//p' "$manifest")"
if [[ -z "$version" ]] || [[ "$version" == *[!0-9A-Za-z.-]* ]]; then
   echo "error: invalid or missing version in $manifest" >&2
   exit 1
fi

archive="$dist_dir/TDArenaLens-$version.zip"
mkdir -p "$dist_dir"
rm -f "$archive"

(
   cd "$repo_root"
   find TDArenaLens -type f -print0 \
      | LC_ALL=C sort -z \
      | xargs -0 zip -X -q "$archive"
)

echo "Created $archive"

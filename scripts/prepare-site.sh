#!/usr/bin/env bash
# Assemble the existing static files; this is packaging, not a build step.
set -euo pipefail

if [[ ${1:-} == --help ]]; then
  printf 'Usage: bash scripts/prepare-site.sh [NEW_OUTPUT_DIRECTORY_OUTSIDE_CHECKOUT]\n'
  printf 'Without a directory, creates a new temporary directory and prints its path.\n'
  exit 0
fi
if (( $# > 1 )); then
  printf 'Expected at most one new output directory.\n' >&2
  exit 2
fi

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
for file in index.html styles.css script.js; do
  if [[ ! -s "$repo_dir/$file" || -L "$repo_dir/$file" ]]; then
    printf 'Missing, empty or symbolic-link site file: %s\n' "$file" >&2
    exit 1
  fi
done
if [[ ! -d "$repo_dir/assets" || -L "$repo_dir/assets" ]]; then
  printf 'Expected a local assets directory.\n' >&2
  exit 1
fi
if [[ -n $(find "$repo_dir/assets" -type l -print -quit) ]]; then
  printf 'Symbolic links are not allowed in deployment assets.\n' >&2
  exit 1
fi

if (( $# == 1 )); then
  output_dir=$1
  if [[ -e "$output_dir" || -L "$output_dir" ]]; then
    printf 'Refusing to overwrite an existing output directory: %s\n' "$output_dir" >&2
    exit 1
  fi
  output_parent=$(cd -- "$(dirname -- "$output_dir")" && pwd -P)
  output_dir="$output_parent/$(basename -- "$output_dir")"
  case "$output_dir" in
    "$repo_dir"|"$repo_dir"/*)
      printf 'Choose an output directory outside the checkout.\n' >&2
      exit 1
      ;;
  esac
  mkdir -- "$output_dir"
else
  output_dir=$(mktemp -d "${TMPDIR:-/tmp}/harqmedia-site.XXXXXX")
fi
output_dir=$(cd -- "$output_dir" && pwd -P)
cp -- "$repo_dir/index.html" "$repo_dir/styles.css" "$repo_dir/script.js" "$output_dir/"
cp -R -- "$repo_dir/assets" "$output_dir/assets"
printf '%s\n' "$output_dir"

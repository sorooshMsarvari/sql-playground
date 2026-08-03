#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

last_section="$(find "$ROOT_DIR/sections" -mindepth 1 -maxdepth 1 -type d -name '[0-9][0-9]-*' -print | sort | tail -n 1)"
if [[ -z "$last_section" ]]; then
    failure "No numbered sections were found."
    exit 2
fi

last_name="${last_section##*/}"
exec "$ROOT_DIR/scripts/check-section.sh" "${last_name%%-*}" "$@"


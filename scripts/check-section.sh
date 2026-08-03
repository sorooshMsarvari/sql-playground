#!/usr/bin/env bash
set -uo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

usage() {
    printf 'Usage: %s <01..10> [--only] [--solutions]\n' "$0"
    printf 'By default section N checks sections 01 through N (incremental mode).\n'
}

if [[ $# -lt 1 || $# -gt 3 ]]; then
    usage >&2
    exit 2
fi

requested_raw="$1"
shift
only=0
use_solutions=0
for option in "$@"; do
    case "$option" in
        --only) only=1 ;;
        --solutions) use_solutions=1 ;;
        *) failure "Unknown option: $option"; usage >&2; exit 2 ;;
    esac
done

if [[ ! "$requested_raw" =~ ^[0-9]{1,2}$ ]]; then
    failure "Section must be a number such as 03."
    exit 2
fi
requested=$((10#$requested_raw))

ensure_postgres || exit 1

passed=0
failed=0
selected=0
printf '%sIncremental SQL check through section %02d%s\n\n' "$C_BOLD" "$requested" "$C_RESET"

for section_dir in "$ROOT_DIR"/sections/[0-9][0-9]-*; do
    [[ -d "$section_dir" ]] || continue
    section_name="$(basename "$section_dir")"
    section_number=$((10#${section_name%%-*}))
    if [[ $only -eq 1 && $section_number -ne $requested ]]; then
        continue
    fi
    if [[ $only -eq 0 && $section_number -gt $requested ]]; then
        continue
    fi
    selected=1
    for starter in "$section_dir"/exercises/*.sql; do
        [[ -f "$starter" ]] || continue
        if [[ $use_solutions -eq 1 ]]; then
            candidate="$ROOT_DIR/solutions/$section_name/$(basename "$starter")"
        else
            candidate="$starter"
        fi
        if PLAYGROUND_SKIP_READY=1 "$ROOT_DIR/scripts/check.sh" "$candidate"; then
            passed=$((passed + 1))
        else
            failed=$((failed + 1))
        fi
        printf '\n'
    done
done

if [[ $selected -eq 0 ]]; then
    failure "No section matched $requested_raw."
    exit 2
fi

printf '%sSummary:%s %s passed, %s failed\n' "$C_BOLD" "$C_RESET" "$passed" "$failed"
if [[ $failed -eq 0 ]]; then
    success "Everything in scope passed."
    exit 0
fi
failure "Keep going: fix the failed answer files, then run the same command again."
exit 1


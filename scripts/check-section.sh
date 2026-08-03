#!/usr/bin/env bash
set -uo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

usage() {
    printf 'Usage: %s <01..10> [--only] [--exercise <01..99>] [--solutions]\n' "$0"
    printf 'By default section N checks sections 01 through N (incremental mode).\n'
    printf 'Use --only for one whole section or --exercise NN for one exercise.\n'
}

if [[ $# -lt 1 ]]; then
    usage >&2
    exit 2
fi

requested_raw="$1"
shift
only=0
use_solutions=0
exercise_raw=''
while [[ $# -gt 0 ]]; do
    case "$1" in
        --only)
            only=1
            shift
            ;;
        --solutions)
            use_solutions=1
            shift
            ;;
        --exercise)
            if [[ $# -lt 2 || -z "$2" ]]; then
                failure "--exercise requires a number such as 03."
                usage >&2
                exit 2
            fi
            exercise_raw="$2"
            shift 2
            ;;
        *)
            failure "Unknown option: $1"
            usage >&2
            exit 2
            ;;
    esac
done

if [[ ! "$requested_raw" =~ ^[0-9]{1,2}$ ]]; then
    failure "Section must be a number such as 03."
    exit 2
fi
requested=$((10#$requested_raw))

exercise_prefix=''
if [[ -n "$exercise_raw" ]]; then
    if [[ ! "$exercise_raw" =~ ^[0-9]{1,2}$ ]]; then
        failure "Exercise must be a number such as 03."
        exit 2
    fi
    exercise_number=$((10#$exercise_raw))
    if [[ $exercise_number -lt 1 ]]; then
        failure "Exercise number must be at least 01."
        exit 2
    fi
    printf -v exercise_prefix '%02d' "$exercise_number"
    only=1
fi

printf -v requested_label '%02d' "$requested"
section_match_count=0
for matching_section in "$ROOT_DIR"/sections/"$requested_label"-*; do
    [[ -d "$matching_section" ]] || continue
    section_match_count=$((section_match_count + 1))
done
if [[ $section_match_count -eq 0 ]]; then
    failure "No section matched $requested_raw."
    exit 2
fi
if [[ $section_match_count -gt 1 ]]; then
    failure "Multiple section directories matched $requested_label; numbering must be unique."
    exit 2
fi

if [[ -n "$exercise_prefix" ]]; then
    exercise_match_count=0
    for matching_exercise in \
        "$ROOT_DIR"/sections/"$requested_label"-*/exercises/"$exercise_prefix"-*.sql; do
        [[ -f "$matching_exercise" ]] || continue
        exercise_match_count=$((exercise_match_count + 1))
    done
    if [[ $exercise_match_count -eq 0 ]]; then
        failure "Exercise $exercise_prefix was not found in section $requested_label."
        exit 2
    fi
    if [[ $exercise_match_count -gt 1 ]]; then
        failure "Multiple exercises matched $exercise_prefix in section $requested_label."
        exit 2
    fi
fi

ensure_postgres || exit 1

passed=0
failed=0
selected_section=0
selected_exercises=0
if [[ -n "$exercise_prefix" ]]; then
    printf '%sSQL check for section %02d, exercise %s%s\n\n' \
        "$C_BOLD" "$requested" "$exercise_prefix" "$C_RESET"
elif [[ $only -eq 1 ]]; then
    printf '%sSQL check for section %02d%s\n\n' "$C_BOLD" "$requested" "$C_RESET"
else
    printf '%sIncremental SQL check through section %02d%s\n\n' "$C_BOLD" "$requested" "$C_RESET"
fi

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
    selected_section=1
    for starter in "$section_dir"/exercises/*.sql; do
        [[ -f "$starter" ]] || continue
        if [[ -n "$exercise_prefix" ]]; then
            case "$(basename "$starter")" in
                "$exercise_prefix"-*.sql) ;;
                *) continue ;;
            esac
        fi
        selected_exercises=$((selected_exercises + 1))
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

if [[ $selected_section -eq 0 ]]; then
    failure "No section matched $requested_raw."
    exit 2
fi
if [[ $selected_exercises -eq 0 ]]; then
    failure "Exercise $exercise_prefix was not found in section $(printf '%02d' "$requested")."
    exit 2
fi

printf '%sSummary:%s %s passed, %s failed\n' "$C_BOLD" "$C_RESET" "$passed" "$failed"
if [[ $failed -eq 0 ]]; then
    success "Everything in scope passed."
    exit 0
fi
failure "Keep going: fix the failed answer files, then run the same command again."
exit 1

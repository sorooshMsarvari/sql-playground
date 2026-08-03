#!/usr/bin/env bash
set -uo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

usage() {
    printf 'Usage: %s <exercise-or-solution.sql>\n' "$0"
    printf 'Example: %s sections/01-query-foundations/exercises/01-select-products.sql\n' "$0"
}

if [[ $# -ne 1 ]]; then
    usage >&2
    exit 2
fi

answer_input="$1"
if [[ "$answer_input" = /* ]]; then
    answer_file="$answer_input"
else
    answer_file="$ROOT_DIR/$answer_input"
fi

if [[ ! -f "$answer_file" ]]; then
    failure "Answer file not found: $answer_input"
    exit 2
fi

relative="${answer_file#"$ROOT_DIR"/}"
case "$relative" in
    sections/*/exercises/*.sql)
        section_name="${relative#sections/}"
        section_name="${section_name%%/*}"
        file_name="${relative##*/}"
        solution_file="$ROOT_DIR/solutions/$section_name/$file_name"
        ;;
    solutions/*/*.sql)
        section_name="${relative#solutions/}"
        section_name="${section_name%%/*}"
        file_name="${relative##*/}"
        solution_file="$answer_file"
        ;;
    *)
        failure "The file must be under sections/<section>/exercises or solutions/<section>."
        exit 2
        ;;
esac

exercise_id="${file_name%.sql}"
state_test="$ROOT_DIR/tests/$section_name/$exercise_id.test.sql"
hint_file="$ROOT_DIR/tests/$section_name/$exercise_id.hint"

if [[ "${PLAYGROUND_SKIP_READY:-0}" != 1 ]]; then
    ensure_postgres || exit 1
fi

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/sql-playground-check.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT
actual_out="$tmp_dir/actual.csv"
expected_out="$tmp_dir/expected.csv"
actual_err="$tmp_dir/actual.err"

printf '%s▶%s %s / %s\n' "$C_BOLD" "$C_RESET" "$section_name" "$exercise_id"

if [[ -f "$state_test" ]]; then
    {
        printf '\\set ON_ERROR_STOP on\nBEGIN;\nSET search_path TO shop, public;\n'
        printf '\\echo running learner statements\n'
        sed '/^[[:space:]]*\\echo /d' "$answer_file"
        printf '\n\\echo checking resulting database state\n'
        cat "$state_test"
        printf '\nROLLBACK;\n'
    } | psql_base --tuples-only --csv >"$actual_out" 2>"$actual_err"
    status=$?

    if [[ $status -eq 0 ]]; then
        success "$exercise_id passed (changes were rolled back)."
        if [[ -s "$actual_out" ]]; then
            indent_file "$actual_out"
        fi
        exit 0
    fi
else
    if [[ ! -f "$solution_file" ]]; then
        failure "Missing checker solution: ${solution_file#"$ROOT_DIR"/}"
        exit 2
    fi

    combined_out="$tmp_dir/combined.csv"
    boundary='__SQL_PLAYGROUND_REFERENCE_BOUNDARY_9f4a2c__'
    {
        printf '\\set ON_ERROR_STOP on\nBEGIN;\nSET TRANSACTION READ ONLY;\nSET search_path TO shop, public;\n'
        sed '/^[[:space:]]*\\echo /d' "$answer_file"
        printf '\nROLLBACK;\n\\echo %s\n' "$boundary"
        printf 'BEGIN;\nSET TRANSACTION READ ONLY;\nSET search_path TO shop, public;\n'
        sed '/^[[:space:]]*\\echo /d' "$solution_file"
        printf '\nROLLBACK;\n'
    } | psql_base --csv >"$combined_out" 2>"$actual_err"
    status=$?

    boundary_seen=0
    if grep -Fxq "$boundary" "$combined_out"; then
        boundary_seen=1
        awk -v marker="$boundary" -v actual="$actual_out" -v expected="$expected_out" '
            $0 == marker { in_expected = 1; next }
            in_expected { print > expected; next }
            { print > actual }
        ' "$combined_out"
    fi

    if [[ $status -ne 0 ]]; then
        if [[ $boundary_seen -eq 1 ]]; then
            failure "The repository's reference query failed. This is a playground bug."
            indent_file "$actual_err" >&2
            exit 2
        fi
    elif [[ $boundary_seen -ne 1 ]]; then
        failure "The checker could not separate the learner and reference results."
        exit 2
    else
        if cmp -s "$actual_out" "$expected_out"; then
            if [[ "$relative" == sections/*/exercises/*.sql ]] \
                && grep -Eiq 'where[[:space:]]+false' "$answer_file"; then
                failure "$exercise_id still contains the untouched WHERE false starter."
                if [[ -f "$hint_file" ]]; then
                    printf '%sHint:%s ' "$C_CYAN" "$C_RESET" >&2
                    cat "$hint_file" >&2
                    printf '\n' >&2
                fi
                exit 1
            fi
            output_lines=$(wc -l < "$actual_out" | tr -d ' ')
            row_count=$((output_lines - 1))
            if [[ "$relative" == solutions/*/*.sql ]] \
                && [[ "${PLAYGROUND_REQUIRE_REFERENCE_ROWS:-0}" == 1 ]] \
                && [[ $row_count -eq 0 ]]; then
                failure "$exercise_id has an empty reference result; fixture coverage is incomplete."
                exit 2
            fi
            success "$exercise_id passed ($row_count result rows)."
            exit 0
        fi
    fi
fi

failure "$exercise_id did not pass."
if [[ -s "$actual_err" ]]; then
    printf '%sDatabase feedback:%s\n' "$C_YELLOW" "$C_RESET" >&2
    sed -n '1,18p' "$actual_err" | sed 's/^/    /' >&2
elif [[ -f "$state_test" ]]; then
    printf '    The state assertion failed without a PostgreSQL error.\n' >&2
else
    printf '%sResult difference (- expected, + yours):%s\n' "$C_YELLOW" "$C_RESET" >&2
    diff -u --label expected --label yours "$expected_out" "$actual_out" | sed -n '1,45p' >&2 || true
    if [[ $(wc -l < "$actual_out") -gt 20 || $(wc -l < "$expected_out") -gt 20 ]]; then
        printf '    (difference truncated to keep the log readable)\n' >&2
    fi
fi

if [[ -f "$hint_file" ]]; then
    printf '%sHint:%s ' "$C_CYAN" "$C_RESET" >&2
    cat "$hint_file" >&2
    printf '\n' >&2
fi
exit 1

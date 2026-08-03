#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

info "Checking Bash syntax..."
for script in "$ROOT_DIR"/scripts/*.sh; do
    bash -n "$script"
done
success "Bash syntax is valid."

info "Auditing the 100 exercise artifacts and Markdown coverage..."
exercise_count=$(find "$ROOT_DIR/sections" -path '*/exercises/*.sql' -type f | wc -l | tr -d ' ')
solution_count=$(find "$ROOT_DIR/solutions" -name '*.sql' -type f | wc -l | tr -d ' ')
hint_count=$(find "$ROOT_DIR/tests" -name '*.hint' -type f | wc -l | tr -d ' ')
if [[ $exercise_count -ne 100 || $solution_count -ne 100 || $hint_count -ne 100 ]]; then
    failure "Expected 100 exercises, solutions, and hints; found $exercise_count/$solution_count/$hint_count."
    exit 2
fi

for exercise in "$ROOT_DIR"/sections/[0-9][0-9]-*/exercises/*.sql; do
    section_name="$(basename "$(dirname "$(dirname "$exercise")")")"
    file_name="$(basename "$exercise")"
    exercise_id="${file_name%.sql}"
    [[ -f "$ROOT_DIR/solutions/$section_name/$file_name" ]] || {
        failure "Missing solution for $section_name/$file_name"; exit 2;
    }
    [[ -f "$ROOT_DIR/tests/$section_name/$exercise_id.hint" ]] || {
        failure "Missing hint for $section_name/$file_name"; exit 2;
    }
    grep -Fq "$file_name" "$ROOT_DIR/sections/$section_name/README.md" || {
        failure "README does not document $section_name/$file_name"; exit 2;
    }
done
success "All exercise artifacts and documentation references are present."

"$ROOT_DIR/scripts/reset.sh"
info "Running every reference solution through the same checker learners use..."
PLAYGROUND_REQUIRE_REFERENCE_ROWS=1 "$ROOT_DIR/scripts/check-all.sh" --solutions

success "The containers, fixtures, 100 reference answers, and all assertions are healthy."

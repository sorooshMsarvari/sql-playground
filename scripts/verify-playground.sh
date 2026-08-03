#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

info "Checking Bash syntax..."
for script in "$ROOT_DIR"/scripts/*.sh; do
    bash -n "$script"
done
success "Bash syntax is valid."

"$ROOT_DIR/scripts/reset.sh"
info "Running every reference solution through the same checker learners use..."
"$ROOT_DIR/scripts/check-all.sh" --solutions

success "The containers, fixtures, 31 reference answers, and all assertions are healthy."

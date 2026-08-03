#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

if [[ $# -gt 1 || ( $# -eq 1 && "$1" != "--ui" ) ]]; then
    failure "Usage: $0 [--ui]"
    exit 2
fi

info "Starting PostgreSQL..."
compose up -d postgres
wait_for_postgres

success "SQL playground is ready."
printf '  PostgreSQL: localhost:%s (database/user/password: sql_playground/sql_student/sql_student)\n' "${POSTGRES_PORT:-5432}"
if [[ "${1:-}" == "--ui" ]]; then
    info "Starting the optional Adminer UI..."
    compose --profile ui up -d adminer
    printf '  Adminer:    http://localhost:%s\n' "${ADMINER_PORT:-8080}"
else
    printf '  Adminer:    optional; run ./scripts/start.sh --ui\n'
fi
printf '  First task: edit sections/01-query-foundations/exercises/01-select-products.sql\n'

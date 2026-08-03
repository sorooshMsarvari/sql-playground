#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ensure_postgres
warn "Resetting the shop and training schemas to the original fixtures..."

for fixture in \
    "$ROOT_DIR/fixtures/00_schema.sql" \
    "$ROOT_DIR/fixtures/10_seed.sql" \
    "$ROOT_DIR/fixtures/20_training_helpers.sql"; do
    info "Loading $(basename "$fixture")"
    psql_base < "$fixture" >/dev/null
done

success "Fixtures restored: 14 customers, 17 products, 24 orders, and 50 order items."

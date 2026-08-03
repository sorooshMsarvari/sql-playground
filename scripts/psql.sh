#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
ensure_postgres
exec docker compose --project-directory "$ROOT_DIR" exec postgres \
    psql -X -U sql_student -d sql_playground


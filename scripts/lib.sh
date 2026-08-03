#!/usr/bin/env bash

set -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    C_RESET=$'\033[0m'
    C_BOLD=$'\033[1m'
    C_GREEN=$'\033[32m'
    C_RED=$'\033[31m'
    C_YELLOW=$'\033[33m'
    C_CYAN=$'\033[36m'
else
    C_RESET=''
    C_BOLD=''
    C_GREEN=''
    C_RED=''
    C_YELLOW=''
    C_CYAN=''
fi

info()    { printf '%sℹ%s %s\n' "$C_CYAN" "$C_RESET" "$*"; }
success() { printf '%s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn()    { printf '%s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*"; }
failure() { printf '%s✗%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }

compose() {
    docker compose --project-directory "$ROOT_DIR" "$@"
}

wait_for_postgres() {
    local attempt
    for attempt in $(seq 1 40); do
        if compose exec -T postgres pg_isready -U sql_student -d sql_playground >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done
    failure "PostgreSQL did not become ready within 40 seconds."
    compose logs --tail=30 postgres >&2 || true
    return 1
}

ensure_postgres() {
    if ! command -v docker >/dev/null 2>&1; then
        failure "Docker is required but was not found. Install Docker Desktop or Docker Engine."
        return 1
    fi
    if ! docker info >/dev/null 2>&1; then
        failure "Docker is installed, but its daemon is not running. Start Docker and try again."
        return 1
    fi
    if [[ -z "$(compose ps --status running -q postgres 2>/dev/null)" ]]; then
        info "Starting the PostgreSQL container..."
        compose up -d postgres
    fi
    wait_for_postgres
}

psql_base() {
    compose exec -T postgres psql \
        -X \
        --set ON_ERROR_STOP=1 \
        --username sql_student \
        --dbname sql_playground \
        --quiet \
        --no-psqlrc \
        --pset pager=off \
        "$@"
}

indent_file() {
    sed 's/^/    /' "$1"
}


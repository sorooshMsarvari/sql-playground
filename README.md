# SQL Exercise Playground

A hands-on PostgreSQL curriculum that grows from the first `SELECT` to recursive CTEs, window functions, data modification, schema design, indexes, JSONB, and a reporting capstone. It contains 10 mentally related sections and 100 incrementally checked exercises.

Everything runs in Docker. You do not need PostgreSQL, `psql`, or a language runtime installed on the host.

## Quick start

Requirements: Docker Desktop or Docker Engine with Compose v2.

```bash
./scripts/start.sh
```

Edit the first starter:

```text
sections/01-query-foundations/exercises/01-select-products.sql
```

Then check it:

```bash
./scripts/check.sh sections/01-query-foundations/exercises/01-select-products.sql
```

Check your progress incrementally through section 3:

```bash
./scripts/check-section.sh 03
```

That command checks sections 01, 02, and 03. Use `--only` when you want only the named section:

```bash
./scripts/check-section.sh 03 --only
```

Check one exact exercise by its numbered filename prefix:

```bash
./scripts/check-section.sh 03 --exercise 05
make check SECTION=03 EXERCISE=05
```

Both `5` and `05` are accepted. `--exercise` automatically limits the run to the specified section.

## Exercise distribution

| Section | Exercises |
|---|---:|
| 01 — Query foundations | 10 |
| 02 — Expressions and NULLs | 10 |
| 03 — Aggregation | 12 |
| 04 — Joins | 12 |
| 05 — Subqueries and sets | 10 |
| 06 — CTEs and recursion | 8 |
| 07 — Window functions | 12 |
| 08 — Data modification | 10 |
| 09 — Schema and performance | 8 |
| 10 — PostgreSQL and capstone | 8 |
| **Total** | **100** |

## Daily practice loop

1. Read the numbered section's `README.md`. It is the canonical, complete question: it includes the relevant schema, relationships, business context, output contract, edge cases, and ordering rules.
2. Open the linked file in that section's `exercises/` directory and replace the starter query or add the requested statements. Comments in `.sql` files are intentionally compact reminders, not the full question.
3. Run that file's checker. Read the PostgreSQL error, result diff, or focused hint.
4. Iterate until it passes, then move to the next exercise.
5. Look at the matching file under `solutions/` only after you have a working answer or are truly stuck.

The checker is deliberately strict about column order, row order, rounding, and requested semantics. In production those details are part of a query's contract.

## Services and access

`./scripts/start.sh` starts a real `postgres:16-alpine` container. Add `--ui` to start the optional browser interface as a second container:

```bash
./scripts/start.sh --ui
```

The images are:

- `postgres:16-alpine` — the database and command-line client
- `adminer:4-standalone` — an optional web database UI at [http://localhost:8080](http://localhost:8080), enabled with `--ui`

Adminer login:

| Field | Value |
|---|---|
| System | PostgreSQL |
| Server | `postgres` |
| Username | `sql_student` |
| Password | `sql_student` |
| Database | `sql_playground` |

Open an interactive SQL shell with:

```bash
./scripts/psql.sh
```

Useful `psql` commands are `\dt` (tables), `\d products` (describe a table), `\x` (expanded display), and `\q` (quit).

If ports 5432 or 8080 are occupied, copy `.env.example` to `.env` and change the host-side ports.

## Commands

| Command | Purpose |
|---|---|
| `make start` | Start PostgreSQL and wait for health |
| `make start-ui` | Start PostgreSQL plus the optional Adminer browser UI |
| `make psql` | Enter an interactive PostgreSQL shell |
| `make check SECTION=04` | Check every exercise in section 04 |
| `make check SECTION=04 EXERCISE=05` | Check only exercise 05 in section 04 |
| `make check-all` | Check all of your starter/answer files |
| `make reset` | Recreate the schemas and deterministic seed data |
| `make verify` | Reset and test all 100 supplied reference solutions |
| `make logs` | Follow PostgreSQL logs |
| `make stop` | Stop containers without deleting the database volume |

`docker compose down -v` also deletes the database volume. This is safe for the supplied fixtures, but it deletes any experiments you added. `make reset` is usually the better choice.

## How checking works

Query exercises run your SQL and the reference query independently in read-only transactions. Their ordered CSV results are compared, so formatting noise does not obscure the meaningful difference.

Data-changing and schema exercises run your statements followed by database assertions in one transaction. That transaction is always rolled back, making the check repeatable. Error output is capped and result diffs are truncated to keep logs readable. Every exercise has a short contextual hint.

Run `NO_COLOR=1 ./scripts/check-section.sh 04` for plain logs in CI or text files. See [docs/CHECKER.md](docs/CHECKER.md) for the exact contracts.

## Repository map

```text
.
├── docker-compose.yml       PostgreSQL and Adminer
├── fixtures/                schema, deterministic seed, assertion helper
├── sections/01-.../         lesson notes and editable exercise files
├── sections/10-.../
├── solutions/               matching reference answers
├── tests/                   state assertions and focused hints
├── scripts/                 lifecycle and checking commands
├── ROADMAP.md               complete learning sequence
└── docs/                    data model and checker details
```

The main dataset models a small European commerce business. It is intentionally rich enough for nullable relationships, products with no sales, customers with no orders, payment mismatches, an employee tree, incomplete inventory, JSON properties, and historical line prices.

Start with [ROADMAP.md](ROADMAP.md), then keep [docs/DATA_MODEL.md](docs/DATA_MODEL.md) nearby while solving joins.

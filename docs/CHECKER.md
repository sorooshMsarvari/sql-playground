# Checker contracts

## Query exercises

Each editable `.sql` file must emit exactly one final result set with the requested columns and order. The checker:

1. opens a read-only transaction;
2. executes the learner file with `ON_ERROR_STOP`;
3. rolls back;
4. executes the matching reference query the same way;
5. compares CSV output, including column names, byte-for-byte.

This makes duplicate rows, `NULL`, exact money formatting, column order, and row order observable. Command tags are quieted. A mismatch prints a bounded unified diff with `-` for expected rows and `+` for learner rows.

## State exercises

When `tests/<section>/<exercise>.test.sql` exists, the checker uses state mode. It begins a transaction, executes the learner statements, runs the assertions, and rolls back. PostgreSQL constraint errors and `training.assert_true` messages become feedback.

An answer must not issue `COMMIT` or `ROLLBACK`; the harness owns the transaction. State checks can be repeated without accumulating rows, price changes, tables, views, or indexes.

## Incremental checks

`./scripts/check-section.sh 06` runs every exercise from sections 01 through 06. This deliberate repetition catches regressions while later tasks build on earlier concepts. `--only` narrows it to section 06.

`./scripts/check-all.sh --solutions` is a repository self-test. `./scripts/verify-playground.sh` additionally checks shell syntax and resets fixtures before running all reference files.

## Feedback and exit codes

- Exit 0: the exercise or requested scope passed.
- Exit 1: a learner answer failed or PostgreSQL was unavailable.
- Exit 2: invocation or repository configuration error.

Set `NO_COLOR=1` for log files and CI. Errors and diffs are intentionally truncated; rerun the SQL in `./scripts/psql.sh` when you need unrestricted exploratory output.

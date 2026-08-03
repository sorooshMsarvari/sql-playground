# SQL learning roadmap

This sequence alternates new syntax with the reasoning habit it supports. The 10 repository sections are the core path; the final phase lists production topics to study after the playground.

## Phase A — Read and shape data

### 01. Query foundations

Learn `SELECT`, aliases, `FROM`, `WHERE`, comparison operators, `AND`/`OR`/`NOT`, `IN`, `BETWEEN`, `LIKE`/`ILIKE`, `ORDER BY`, `LIMIT`, and deterministic ordering.

Reasoning goal: describe the exact output grain, columns, eligible rows, and order before writing SQL.

### 02. Expressions, types, and missing values

Learn arithmetic, operator precedence, casts, numeric precision, `CASE`, `COALESCE`, `NULLIF`, `IS NULL`, three-valued logic, string functions, date/time types, intervals, and date arithmetic.

Reasoning goal: distinguish stored facts from derived facts, and treat `NULL` as unknown/missing rather than as an ordinary value.

### 03. Aggregation

Learn `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `DISTINCT`, `GROUP BY`, `HAVING`, aggregate `FILTER`, and conditional aggregation.

Reasoning goal: state the grouping grain in plain language and prevent accidental double-counting.

## Phase B — Relate and compose data

### 04. Joins

Learn inner, left, right, full, cross, and self joins; primary/foreign keys; cardinality; optional relationships; join predicates; and fan-out.

Reasoning goal: predict how many rows each join can produce and decide which unmatched rows must survive.

### 05. Subqueries and set operations

Learn scalar and correlated subqueries, `EXISTS`/`NOT EXISTS`, `IN`, derived tables, `LATERAL`, `UNION`/`UNION ALL`, `INTERSECT`, and `EXCEPT`.

Reasoning goal: choose between joining, testing existence, and combining compatible row sets.

### 06. CTEs and recursion

Learn `WITH`, multi-stage query design, CTE materialization considerations, `WITH RECURSIVE`, termination, hierarchy paths, `generate_series`, and calendar tables.

Reasoning goal: make each stage produce a clear, testable grain before feeding the next stage.

## Phase C — Analyze ordered data

### 07. Window functions

Learn `OVER`, `PARTITION BY`, window ordering, frames, `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, running aggregates, moving averages, percentiles, and top-N per group.

Reasoning goal: preserve detail rows while comparing each row with peers, previous rows, or cumulative history.

## Phase D — Change and design data safely

### 08. DML and transactions

Learn `INSERT`, `UPDATE`, `DELETE`, `RETURNING`, upserts with `ON CONFLICT`, transactions, atomicity, savepoints, locking basics, isolation levels, and lost-update prevention.

Reasoning goal: define invariants, inspect the target set, make related changes atomically, and verify affected rows.

### 09. Schema design and performance

Learn tables and data types, identity keys, primary/foreign/unique/check constraints, normalization, views, indexes, multicolumn ordering, covering and partial indexes, statistics, and `EXPLAIN (ANALYZE, BUFFERS)`.

Reasoning goal: put durable integrity in the database and optimize measured access patterns, not guesses.

## Phase E — PostgreSQL depth and synthesis

### 10. JSONB and capstone reporting

Learn JSONB extraction and containment, arrays, `FILTER`, `DISTINCT ON`, date truncation, reusable reporting layers, and a composed analytics query using joins, CTEs, aggregation, JSONB, and windows.

Reasoning goal: use vendor-specific features intentionally while keeping relational structure and output contracts clear.

## Phase F — Production SQL after this playground

Continue with:

- Query-plan diagnosis on production-sized data, statistics, vacuuming, index maintenance, and partitioning
- Concurrency experiments across two sessions: locks, deadlocks, MVCC, and isolation anomalies
- Roles, privileges, row-level security, secrets, and least-privilege application access
- Migrations, backward-compatible schema changes, online index creation, and rollback planning
- Backup/restore, replication, high availability, observability, and capacity management
- Dynamic SQL, stored procedures, triggers, audit trails, and when business logic belongs elsewhere
- Data warehousing: facts/dimensions, star schemas, slowly changing dimensions, incremental models, and data quality tests
- Dialect translation among PostgreSQL, MySQL, SQL Server, SQLite, BigQuery, Snowflake, and DuckDB

For durable mastery, revisit each solved task with a changed requirement: include empty groups, add ties, introduce `NULL`, scale rows by 1,000×, or demand concurrency safety. SQL skill grows fastest when the happy path stops being the only path.


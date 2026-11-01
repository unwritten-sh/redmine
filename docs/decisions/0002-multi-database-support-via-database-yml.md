# 0002. Support several databases, chosen in config/database.yml

- Status: inferred from the code, to be confirmed by the team
- Date: 2026-11-01

## Context

Redmine is self-hosted. Each organization runs it on the database it already operates: MySQL or MariaDB, PostgreSQL, SQLite3 or SQL Server.

## Decision

The application supports all four through ActiveRecord. `config/database.yml` (ignored by git, examples in `config/database.yml.example`) names the adapter. The `Gemfile` reads that file and installs only the adapter gems it finds (`mysql2` or `trilogy`, `pg`, `sqlite3`, `tiny_tds` with `activerecord-sqlserver-adapter`). CI runs the test suite on PostgreSQL 14, MySQL 8.4 and SQLite3 (`.github/workflows/tests.yml`).

## Consequences

- `config/database.yml` must exist before `bundle install`. Without it, no adapter gem is installed and nothing can run. `bin/harness setup` writes a SQLite3 file when none exists.
- Migrations and SQL in models must work on every adapter. Code that is adapter-specific checks `Redmine::Database` (`lib/redmine/database.rb`).
- The harness gates use SQLite3 only. PostgreSQL and MySQL are covered by `.github/workflows/tests.yml`, or locally with `compose.yaml`.

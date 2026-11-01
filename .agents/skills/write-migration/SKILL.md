---
name: write-migration
description: Use when a Redmine change needs a new table, column, index or data migration in db/migrate.
---

# Write a migration

1. Look at recent migrations for the style: `ls db/migrate | tail -5`. New files use a timestamp prefix and the current Rails version, for example `class AddAvatarIdToUsers < ActiveRecord::Migration[8.1]`.
2. Generate the file: `bin/rails generate migration AddFooToIssues foo:string`, then edit it in `db/migrate/`.
3. Keep it portable. Redmine runs on SQLite3, PostgreSQL, MySQL and SQL Server (see `docs/decisions/0002-multi-database-support-via-database-yml.md`). Use ActiveRecord methods (`add_column`, `add_index`, `change_column_default`) instead of raw SQL. When raw SQL cannot be avoided, branch on `Redmine::Database.postgresql?`, `.mysql?`, `.sqlite?`, `.sqlserver?` (`lib/redmine/database.rb`).
4. Prefer a reversible `change` method; write `up` and `down` when Rails cannot reverse it. Do not use application models with their current code in data migrations: define a small model class inside the migration if you need one.
5. Apply it to both databases: `bin/rails db:migrate` and `RAILS_ENV=test bin/rails db:migrate`. Check the rollback: `bin/rails db:rollback` then `bin/rails db:migrate`.
6. Update the fixtures in `test/fixtures/` if the new column must have values in tests, and add a unit test for the new behavior.
7. Run `bin/harness check`. To try PostgreSQL or MySQL locally, start one with `docker compose up -d postgres` and follow `docs/local-dev.md` (Other databases). CI runs all three databases in `.github/workflows/tests.yml`.
8. `db/schema.rb` is generated and ignored by git: never commit it. Never edit or delete an existing migration.

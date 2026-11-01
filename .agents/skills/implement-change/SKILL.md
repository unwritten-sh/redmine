---
name: implement-change
description: Use when you take a task (bug fix, feature, refactor) in Redmine and need to go from the request to a verified change.
---

# Implement a change

1. Make sure the environment is ready: `bin/harness setup` (safe to run again). It writes `config/database.yml` for SQLite3 if missing, installs gems and prepares the databases.
2. Find the code. Start from the route in `config/routes.rb`, then the controller in `app/controllers`, the model in `app/models` and the library code in `lib/redmine`. `docs/product.md` maps each use case to its entry points; `docs/architecture.md` explains the components.
3. Find the existing tests for that code: `test/unit/<model>_test.rb`, `test/functional/<controller>_test.rb`, `test/integration/` (API tests in `test/integration/api_test/`), `test/system/` (browser). Test data comes from `test/fixtures/*.yml`.
4. Write or update a test first and run it alone: `bin/rails test test/unit/issue_test.rb -n test_create` (use `-n /pattern/` for several).
5. Make the change. Keep the existing style: RuboCop config in `.rubocop.yml`, hash rockets are common in old code, user-visible strings go in `config/locales/en.yml`.
6. If the change needs a schema change, follow the `write-migration` skill. If it touches JavaScript or CSS, follow the `frontend-stimulus` skill.
7. Run the fast gate: `bin/harness check-fast` (RuboCop, Stylelint, unit and helper tests, about 40 s). Fix every offense and failure. `bundle exec rubocop -a <file>` fixes most style offenses.
8. When the change touches controllers, views, routes or the API, run the full gate: `bin/harness check` (all tests except system tests, about 3 minutes). For UI behavior, also run the system test you changed: `bin/rails test test/system/issues_test.rb` (needs Google Chrome).
9. Write the commit message in the upstream style: one imperative sentence ending with the redmine.org issue number, for example `Fix missing Gantt expanders for projects with only subprojects (#44694).` See `docs/agreements/working-agreements.md`.
10. Add a dated entry to `docs/harness/log.md` for a significant change: what changed, what you learned, what is left.

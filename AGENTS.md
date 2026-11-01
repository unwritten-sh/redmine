# AGENTS.md

Redmine is a flexible, open-source project management web application (issues, time tracking, Gantt, wiki, forums, repositories) built with Ruby on Rails 8.1. This repository is a git mirror of the official Subversion repository; upstream development happens on www.redmine.org (see [CONTRIBUTING.md](CONTRIBUTING.md)).

## Commands

All tasks go through `bin/harness <task>`: it picks a Ruby between 3.3 and 4.0, then runs the task from the root `Rakefile`. After setup, `bundle exec rake` with the same task name is equivalent.

| What | Command |
| --- | --- |
| List tasks | `bin/harness help` |
| Setup (database.yml for SQLite3, gems, Stylelint, databases, test repositories, git hooks) | `bin/harness setup` |
| Run the app on http://localhost:3000 (login `admin`) | `bin/harness dev` |
| Lint (RuboCop + Stylelint) | `bin/harness lint` |
| Fast gate: lint + unit and helper tests, about 40 s | `bin/harness check-fast` (or `bundle exec rake check-fast`) |
| Full gate: lint + all tests except system + autoload, about 3 min | `bin/harness check` (or `bundle exec rake check`) |
| All tests except system tests | `bin/rails test` |
| One file / one test | `bin/rails test test/unit/issue_test.rb` / `bin/rails test test/unit/issue_test.rb -n test_create` |
| System tests (need Chrome) | `bin/harness test-system` |
| Console | `bin/rails console` |

More on tests: `doc/RUNNING_TESTS`. Local environment, other databases and common problems: [docs/local-dev.md](docs/local-dev.md).

## Layout

- `app/controllers`, `app/models`, `app/views`, `app/helpers`: the Rails application. `app/models/repository/` holds one class per SCM.
- `app/views/**/*.api.rsb`: XML/JSON builders of the REST API.
- `app/javascript/controllers`: Stimulus controllers, served by importmap (`config/importmap.rb`). `app/assets/stylesheets`: CSS.
- `app/jobs`: ActiveJob jobs (`WebhookJob`, project deletion).
- `lib/redmine/`: core library: access control, plugin API, wiki formatting, exports, SCM adapters.
- `lib/tasks/`: upstream Rake tasks (email, reminders, CI, test repositories). Harness tasks are in `Rakefile`.
- `config/routes.rb`: all routes. `config/*.example`: templates for the git-ignored `database.yml`, `configuration.yml`, `additional_environment.rb`.
- `db/migrate/`: migrations (`db/schema.rb` is generated and ignored).
- `test/unit`, `test/functional`, `test/integration`, `test/system`, `test/helpers`: Minitest suites. `test/fixtures`: YAML fixtures and SCM test repositories.
- `extra/`: mail handler script, SVN integration (`reposman.rb`, `Redmine.pm`), sample plugin.
- `plugins/`, `themes/`: local extensions (ignored by git).
- `doc/`: upstream install, upgrade, changelog. `docs/`: harness knowledge (this index links to it).

## Conventions

- Ruby style is RuboCop (`.rubocop.yml`, `.rubocop_todo.yml`); `lib/tasks/**`, `bin/**` and `extra/**` are excluded upstream. CSS style is Stylelint (`.stylelintrc`).
- Code must work on SQLite3, PostgreSQL, MySQL and SQL Server: [docs/decisions/0002-multi-database-support-via-database-yml.md](docs/decisions/0002-multi-database-support-via-database-yml.md).
- No JavaScript build step: [docs/decisions/0003-importmap-stimulus-without-js-build.md](docs/decisions/0003-importmap-stimulus-without-js-build.md).
- User-visible strings go in `config/locales/en.yml`.
- Commit message: one imperative sentence ending with the redmine.org issue, for example `Fix missing Gantt expanders for projects with only subprojects (#44694).` Details: [docs/agreements/working-agreements.md](docs/agreements/working-agreements.md).

## How to verify a change

1. Add or update a test next to the code you change (`test/unit/<model>_test.rb`, `test/functional/<controller>_test.rb`, ...) and run it alone.
2. Run `bin/harness check-fast` before you say a change is done. It must pass.
3. Run `bin/harness check` when you touch controllers, views, routes or the API. CI runs it through `npx -y uw-harness verify` (`.github/workflows/harness.yml`).
4. After each significant change, add a dated entry to [docs/harness/log.md](docs/harness/log.md): what changed, what you learned, what is left.

## Never do

- Never push to `master` or a `X.Y-stable` branch; a human reviews every change.
- Never edit or delete an existing migration in `db/migrate`. Never commit `db/schema.rb`, `config/database.yml`, `Gemfile.lock` or anything in `files/`, `tmp/`, `log/` (all ignored).
- Never delete a test or add RuboCop or Stylelint exclusions to get a green gate.
- Never edit upstream files for local needs (`doc/*`, `README.rdoc`, `CONTRIBUTING.md`, `.github/workflows/tests.yml`, `.github/workflows/linters.yml`); add new files.
- Never commit secrets. Settings live in git-ignored YAML files; see [.env.example](.env.example).

## Where to find more

- [docs/product.md](docs/product.md): users, use cases with entry points, glossary.
- [docs/architecture.md](docs/architecture.md): components, data stores, external services.
- [docs/local-dev.md](docs/local-dev.md): setup, daily run, reset, debug.
- [docs/deploy.md](docs/deploy.md) and [docs/observability.md](docs/observability.md): what the code shows, open questions for humans.
- [docs/decisions/](docs/decisions/): architecture decision records.
- Skills in [.agents/skills/](.agents/skills/): `implement-change`, `debug-local`, `write-migration`, `frontend-stimulus`.

# Local development

All tasks go through `bin/harness <task>`. The script picks a Ruby between 3.3 and 4.0 (it falls back to Homebrew Ruby on macOS when `/usr/bin/ruby` is too old), then runs the task from the root `Rakefile`. Once gems are installed, `bundle exec rake` with the same task name does the same thing. `bin/harness help` lists the tasks.

## Prerequisites

- Ruby >= 3.3 and < 4.1 (`Gemfile`). `.tool-versions` pins 4.0.0 for asdf or mise. CI tests 3.3, 3.4 and 4.0.
- Bundler (comes with Ruby).
- Node.js 20 and Yarn 1 (or npm), only for Stylelint.
- SQLite3 (the default database).
- Optional, for the repository tests and features: `svn`/`svnadmin`, `git`, `hg`, `bzr`, `cvs`. Tests skip an SCM when its binary or test repository is missing.
- Optional: ImageMagick and Ghostscript (thumbnails, Gantt PNG), Pandoc, Google Chrome (system tests), Docker (PostgreSQL or MySQL instead of SQLite3).

## First run

```sh
bin/harness setup
bin/harness dev
```

`bin/harness setup` does, in order:

1. Writes `config/database.yml` with SQLite3 databases `db/redmine_development.sqlite3` and `db/redmine_test.sqlite3`, if the file does not exist. The `Gemfile` reads this file to pick the adapter gem, so it must exist before `bundle install`.
2. `bundle install`, then `yarn install` (or `npm install`).
3. Creates and migrates the development database, loads the default data in English (`REDMINE_LANG=en`).
4. Creates and migrates the test database.
5. Unpacks the SCM test repositories into `tmp/test` (Subversion and Mercurial only when `svnadmin` or `hg` is installed).
6. Sets `git config core.hooksPath .githooks`, so that `.githooks/pre-push` runs the fast gate.

Then open http://localhost:3000 and log in as `admin` / `admin` (created by the migrations; Redmine asks for a new password at first login).

## Daily run

- `bin/harness dev`: development server.
- `bin/rails console`: Rails console on the development database.
- `bin/harness check-fast`: before every push (the pre-push hook runs it).
- `bin/harness check`: before asking for review.
- One test file or one test: `bin/rails test test/unit/issue_test.rb` and `bin/rails test test/unit/issue_test.rb -n test_create`. More in `doc/RUNNING_TESTS`.
- `PARALLEL_WORKERS=1` runs tests in one process (easier to debug). The gates default to the CPU count.

The gates do not run the system tests (Chrome), and tests that need a missing SCM binary or an LDAP server skip. The upstream workflow `.github/workflows/tests.yml` runs them.

> [!WARNING]
> **Needs a human.** Is it acceptable that the fast gate skips the SCM, LDAP and system (Chrome) tests that need external binaries or services?
> Why it matters and how to do it: https://docs.unwritten.sh/harness/requirements/fast-gate/
<!-- uw-harness:todo fast-gate -->

## Other databases

> [!WARNING]
> **Needs a human.** Which database should be the default for local development and the gates: SQLite3 (the current default of `bin/harness setup`) or PostgreSQL/MySQL in Docker?
> Why it matters and how to do it: https://docs.unwritten.sh/harness/requirements/local-env/
<!-- uw-harness:todo local-env -->

`compose.yaml` starts PostgreSQL 14 or MySQL 8.4 with the same settings as `.github/workflows/tests.yml`:

```sh
docker compose up -d postgres
```

Then write `config/database.yml` by hand (adapter `postgresql`, host `127.0.0.1`, username `root`, password `root`; see `config/database.yml.example`) and run `bin/harness setup` again so that Bundler installs the adapter gem.

## Reset

- Development database: `rm db/redmine_development.sqlite3` then `bin/harness setup`.
- Test database: `rm db/redmine_test.sqlite3` then `bin/harness setup`.
- SCM test repositories: `rm -rf tmp/test/*_repository` then `bin/harness setup`.
- Caches: `bin/rails tmp:cache:clear`.

## Debug

- Logs: `log/development.log` and `log/test.log` (log level `debug` outside production, `config/application.rb`).
- Breakpoints: the `debug` gem is in the development and test groups. Add `debugger` in the code, then run the server or one test with `PARALLEL_WORKERS=1`.
- N+1 queries: the `bullet` gem is in the development group (`config/environments/development.rb`).
- Data: test data is in `test/fixtures/*.yml`. Development data: `bin/rails console` or `bin/rails dbconsole`.
- Admin > Information (`/admin/info`) shows which optional tools (ImageMagick, Ghostscript, Pandoc, Mermaid) the app found.

## Common problems

- `Please configure your config/database.yml first` or no adapter gem: run `bin/harness setup`, or create `config/database.yml` before `bundle install`.
- `Ruby >= 3.3 and < 4.1 is required`: install a newer Ruby (Homebrew `ruby`, asdf or mise with `.tool-versions`).
- `Subversion test repository NOT FOUND` or `Mercurial test repository NOT FOUND`: those tests skip. Install the binary and run `bin/harness setup` again.
- `Skipping LDAP tests`: no LDAP server on `REDMINE_TEST_LDAP_SERVER` (default `127.0.0.1`). Expected locally.
- A plugin in `plugins/` breaks boot or tests: move it out, then run the gates again. Plugin Gemfiles are evaluated by the main `Gemfile`.
- Environment variables that the code and tests read are listed in `.env.example`. Redmine does not load a `.env` file.

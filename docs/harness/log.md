# Implementation log

One entry per significant change, appended at the end: date, what changed, what was learned, what is left.

## Notes from the harness build

- The gates were verified on macOS with Homebrew Ruby 4.0.0, SQLite3, Node 25 and `svn` installed. `bin/harness check-fast` took about 40 s (RuboCop on 1099 files, Stylelint, 3383 unit and helper tests, 0 failures, 92 skips). `bin/harness check` took about 3 minutes (6296 tests, 0 failures, 131 skips, plus 1 autoload test).
- The harness tasks are in the root `Rakefile` and not in `lib/tasks/harness.rake`, because `uw-harness` reads task names only from the `Rakefile`. Unlike `lib/tasks/`, the `Rakefile` is inspected by RuboCop, so every harness task depends on `:environment` (cop `Rails/RakeEnvironment`). That costs about one second per task; the Rails environment loads without a database.
- `bin/harness` exists because the `Rakefile` loads Rails: `rake` cannot run before `config/database.yml` exists and gems are installed. It also falls back to `/opt/homebrew/opt/ruby/bin` (or `/usr/local/opt/ruby/bin`) when the Ruby on PATH is older than 3.3, as on macOS.
- Left out of `bin/harness check`, still run by the upstream workflows: system tests (`bin/harness test-system`, need Chrome and a Mermaid.js download), the Bazaar non-ASCII test (needs the `en_US.ISO8859-1` locale), `bundle audit` (needs network), the PostgreSQL and MySQL jobs and the Ruby 3.3 and 3.4 matrix (`.github/workflows/tests.yml`, `.github/workflows/linters.yml`).
- No test was skipped or deleted by the harness. Skips come from the tests themselves: Mercurial, Bazaar and CVS tests skip when their binaries are missing, and LDAP tests skip without an LDAP server.
- Finding: on a new SQLite3 database, `bin/rails db:prepare` fails every time at migration 072 (`db/migrate/072_add_enumerations_position.rb`) with `no such column: enumerations.position`. The migration skips `add_column` when `Enumeration.column_names` already lists `position`, so stale column information makes it fail. `bin/rails db:create db:migrate` passes every time (CI uses it too, through `ci:setup`). `bin/harness setup` therefore uses `db:create db:migrate`. The migration was not changed; a human should decide whether to fix it upstream.
- `.tool-versions` pins Ruby 4.0.0 (the version the gates were verified with, also in the CI matrix) and Node.js 20 (the CI version). `.ruby-version` is ignored by git upstream, so it was not used.

## 2026-11-01: harness built by uw-harness 0.3.0 with claude

Score 19 → 92, level 0 → 2.

The harness uses Rake, the task runner Redmine already has: new tasks in the root Rakefile, plus a bin/harness wrapper that picks a supported Ruby and bootstraps config/database.yml for SQLite3 before bundle install. From a clean shell, `bin/harness setup` works. `bin/harness check-fast` passes in about 40 s (RuboCop, Stylelint, 3383 unit and helper tests, 0 failures). `bin/harness check` passes in about 3 minutes (6296 tests plus the autoload test, 0 failures). No test was skipped, deleted or excluded, and no product code changed. One finding: `db:prepare` always fails at migration 072 on a new database, so setup uses `db:create db:migrate`. Docs, three ADRs (two inferred), four skills, AGENTS.md, a CI workflow running uw-harness verify, a pre-push hook, compose.yaml, .env.example and .tool-versions were added. Seven open questions (deploy, observability, contribution process, CI, default database, skipped tests) are TODO blocks.

**Assessment.** Redmine is a flexible, open-source project management web application built with Ruby on Rails. Stack: Ruby (>= 3.3, < 4.1; CI tests 3.3, 3.4, 4.0), JavaScript (Stimulus controllers via importmap), CSS, Perl (extra/svn/Redmine.pm), Rails 8.1.4, Hotwire Stimulus (stimulus-rails) with importmap-rails, Propshaft asset pipeline, Doorkeeper (OAuth2 provider), Minitest with mocha, Capybara + Selenium (system tests), RuboCop (+performance, +rails), Stylelint, Puma (server in tests and install docs). The full assessment stays in `.git/uw-harness/assessment.md` on the machine that ran uw-harness.

Risks seen before the harness:

- The Gemfile reads config/database.yml (git-ignored) to choose database gems: without that file, bundle install warns and no database adapter is installed, so setup and every gate fail.
- Full test suite is large (about 400 test files) and slow; running it in a fast gate will exceed one minute. Use unit + helpers only for check_fast.
- Many tests need external binaries (svn, git, hg, bzr, cvs, ImageMagick, Ghostscript, Pandoc) or services (LDAP, Chrome for system tests); results vary by machine and some are silently skipped.
- The git repository is a mirror of the upstream Subversion repository (commit messages cite rNNNNN; svn:ignore commits). Harness files added here may conflict with upstream syncs and are not accepted upstream.
- Existing CI runs only on push and does not call a task runner; editing tests.yml or linters.yml could diverge from upstream.

**Before the harness**: `bin/rails test`, ran no test (exit 1).

**Gates verified by the CLI**

- pass: `bin/harness setup`
- pass: `bin/harness check-fast` (3383 tests, 92 skipped)
- pass: `bin/harness check` (6297 tests, 131 skipped)

**Changes that reduce protection or touch the product**, in a separate commit for review:

- M `Rakefile`: changed existing application code

**Dependency and new files to review**

- A `bin/harness`: new file outside the usual harness paths

**Test files that only compare literals** (they protect nothing)

- `extra/sample_plugin/test/integration/routing_test.rb`
- `test/helpers/activities_helper_test.rb`
- `test/system/quick_jump_test.rb`
- `test/system/responsive_menu_test.rb`
- `test/unit/lib/redmine/notifiable_test.rb`
- `test/unit/lib/redmine/wiki_formatting/textile_html_parser_test.rb`

**Secret-looking values already in the repository**

- `db/migrate/001_setup.rb` (password or secret)
- `test/functional/account_controller_test.rb` (password or secret)
- `test/integration/sessions_test.rb` (password or secret)
- `test/unit/lib/redmine/ciphering_test.rb` (password or secret)

**First task to try with the harness:** Add a test for the /up health check route. config/routes.rb exposes GET /up (rails/health#show) for load balancers and uptime monitors, but no test in test/ covers it. Add a routing test and an integration test, so that a change to the routes or to authentication filters cannot break the health check without a failing test.

- Done when: A new routing assertion (for example in test/integration/routing/) checks that GET /up routes to rails/health#show.
- Done when: A new integration test checks that an anonymous GET /up returns 200, also when the setting 'login_required' is enabled.
- Done when: Only files under test/ change, `bin/harness check-fast` and `bin/harness check` pass, and a dated entry is added to docs/harness/log.md.

**Changed files**

- `Rakefile` (task-runner): Kept the upstream lines. Added the harness tasks help, setup, dev, lint, check-fast, check and test-system to the root Rakefile, because uw-harness reads task names only from that file. They wrap bin/rails, RuboCop and Stylelint, and each depends on :environment so that RuboCop stays clean.
- `bin/harness` (fast-gate): New wrapper. It picks a Ruby >= 3.3 and < 4.1, falling back to Homebrew Ruby when /usr/bin/ruby is too old. For setup it writes a SQLite3 config/database.yml if missing and runs bundle install and yarn install. Then it runs bundle exec rake <task>.
- `.github/workflows/harness.yml` (ci): New workflow on pull_request and on push to master: Ruby 4.0, Node 20, svn and hg, then npx -y uw-harness verify. Upstream tests.yml and linters.yml are unchanged.
- `.githooks/pre-push` (hooks): Pre-push hook that runs bin/harness check-fast. rake setup installs it with git config core.hooksPath .githooks.
- `compose.yaml` (local-env): Optional PostgreSQL 14 and MySQL 8.4 services, the same as in tests.yml. The default setup uses SQLite3 and needs neither.
- `docs/local-dev.md` (local-env): Prerequisites, first run, daily run, other databases, reset, debug and common problems. Also TODOs on the default database and on the tests the gates skip.
- `.env.example` (env-example): Lists every environment variable that the code, tests and Rake tasks read, with safe values. It also points to the git-ignored YAML config files and their .example templates.
- `.tool-versions` (toolchain-pinned): ruby 4.0.0 (the version the gates were verified with, also in the CI matrix) and nodejs 20 (the CI version).
- `docs/architecture.md` (architecture): The Mermaid diagram, then one section per component with folders, tech, key tables and the /up health route. Also lists what the repository does not show.
- `docs/product.md` (product): Value proposition, user roles, 10 use cases with their code entry points, and a glossary.
- `docs/decisions/0001-record-architecture-decisions.md` (decisions): The ADR format: context, decision, consequences, plus how to mark inferred records.
- `docs/decisions/0002-multi-database-support-via-database-yml.md` (decisions): Inferred ADR: several databases are supported, and the Gemfile installs the adapter gems named in config/database.yml.
- `docs/decisions/0003-importmap-stimulus-without-js-build.md` (decisions): Inferred ADR: Stimulus with importmap and Propshaft, no JavaScript build step.
- `docs/agreements/working-agreements.md` (agreements): Branch and commit style taken from the git history, rules for agents, and a definition of done that includes the fast gate. Also TODOs on the contribution process and on the CI workflow.
- `docs/deploy.md` (deploy-explicit): Summary of doc/INSTALL and doc/UPGRADING: environments, build, deploy, rollback and checks after a deploy. Two TODO blocks for what the repository does not show.
- `docs/observability.md` (observability): Rails logger, log level and destinations, GET /up, the Admin > Information checklist, and how to tell that something is wrong. One TODO on production logs, error tracking and alerts.
- `docs/harness/log.md` (implementation-log): Log header plus 'Notes from the harness build': gate timings, why the tasks are in the Rakefile, checks left out, the source of skipped tests, and the migration 072 / db:prepare finding.
- `.agents/skills/implement-change/SKILL.md` (skills): From task to verified change: find code and tests, run one test, check-fast, check, commit style, log entry.
- `.agents/skills/debug-local/SKILL.md` (skills): Reproduce, logs, debugger breakpoints, console and fixtures, SCM/LDAP skips, seeds, plugins.
- `.agents/skills/write-migration/SKILL.md` (skills): Portable migrations across SQLite3, PostgreSQL, MySQL and SQL Server: migrate, rollback, fixtures, compose databases.
- `.agents/skills/frontend-stimulus/SKILL.md` (skills): Stimulus controllers, importmap pins, CSS with open-color variables, sprite_icon and icons:generate, Stylelint, system tests.
- `.claude/skills` (skills): Relative symlink to ../.agents/skills.
- `AGENTS.md` (agents-file): 69-line index: what Redmine is, commands, layout, conventions, how to verify (check-fast before done, log entry), what never to do, links to docs and skills.
- `CLAUDE.md` (agents-file): Symlink to AGENTS.md.

**Open questions for a human**

- Is this copy of Redmine deployed anywhere by your team (which server, which environments), or is it only a mirror of upstream used for development? (in `docs/deploy.md`)
- If this copy is deployed: who can deploy, how is a release built for it (git tag, archive, branch), and how do you roll back a release that ran database migrations? (in `docs/deploy.md`)
- Where do production logs go (log/production.log, STDOUT to a collector?), and is there any error tracker, dashboard or alert channel for this instance? (in `docs/observability.md`)
- Should changes from agents follow the upstream process (a patch attached to an issue on www.redmine.org, commit message ending with (#issue)) or a local branch and pull request process in this repository? (in `docs/agreements/working-agreements.md`)
- May the new workflow .github/workflows/harness.yml run on pull requests in this repository, given that upstream development happens in Subversion on www.redmine.org and GitHub pull requests are not reviewed there? (in `docs/agreements/working-agreements.md`)
- Is it acceptable that the fast gate skips the SCM, LDAP and system (Chrome) tests that need external binaries or services? (in `docs/local-dev.md`)
- Which database should be the default for local development and the gates: SQLite3 (the current default of bin/harness setup) or PostgreSQL/MySQL in Docker? (in `docs/local-dev.md`)

**Left undone**

- local-env: On a new SQLite3 database, bin/rails db:prepare fails every time at db/migrate/072_add_enumerations_position.rb (no such column: enumerations.position). The migration skips add_column when Enumeration.column_names already lists the column. bin/harness setup uses db:create db:migrate instead, which passes every time. The migration was not changed: a human should decide whether to fix it upstream.
- env-example: uw-harness flags db/migrate/001_setup.rb as a secret-looking value. It is the SHA1 hash of the default admin password 'admin', which doc/INSTALL documents and which Redmine forces users to change at first login. It is not a real secret, and the migration may not be changed, so this check stays partial.
- full-gate: Left out of bin/harness check: system tests (bin/harness test-system, need Chrome and a Mermaid.js download), the Bazaar non-ASCII test (needs the en_US.ISO8859-1 locale), bundle audit (needs network), and the PostgreSQL/MySQL and Ruby 3.3/3.4 matrix. The upstream workflows tests.yml and linters.yml still run all of them.
- ci: The uw-harness package is not published on npm (npx -y uw-harness returned 404 here), so the new harness.yml workflow will fail until it is published. The gates were checked with the local build of uw-harness (check passes) and run directly from a clean shell.
- deploy-explicit: Without human answers, docs/deploy.md and docs/observability.md keep open TODO blocks, so these two checks stay partial.

## 2026-11-01: tests for the /up health check route

Added `test/integration/routing/health_test.rb` (GET /up routes to `rails/health#show`) and `test/integration/health_test.rb` (anonymous GET /up returns 200 with `login_required` off and on). No application code changed. Learned: `Rails::HealthController` inherits from `ActionController::Base`, not from Redmine's `ApplicationController`, so Redmine's authentication filters do not apply to it today; the integration test guards against a future change that would route /up through them. Also learned: `bin/rails test` as written in AGENTS.md uses the first Ruby on PATH, which is the system Ruby 2.6 on macOS and fails; prefix PATH with `/opt/homebrew/opt/ruby/bin` (what `bin/harness` does internally). Nothing left.

## 2026-11-01: pilot task done with the harness by claude

**Task:** Add a test for the /up health check route. config/routes.rb exposes GET /up (rails/health#show) for load balancers and uptime monitors, but no test in test/ covers it. Add a routing test and an integration test, so that a change to the routes or to authentication filters cannot break the health check without a failing test.

I added two new test files for the GET /up health check. One is a routing test that asserts GET /up goes to rails/health#show. The other is an integration test that asserts an anonymous GET /up returns 200, with login_required set to '0' and set to '1'. No application code changed. Rails::HealthController inherits from ActionController::Base, so Redmine's authentication filters do not apply to it now. The integration test will fail if a future change sends /up through those filters. Both gates pass: check-fast ran 3383 tests and check ran 6299 tests, with 0 failures, and RuboCop found no offenses. I added a dated entry to docs/harness/log.md.

- Status reported by the agent: done. Acceptance criteria met: 3 of 3.
- Gates after the task: pass. Tests before: 6297 tests, 131 skipped. After: 6300 tests, 131 skipped.
- Fix rounds after a gate failed: 0. Questions for a human: 0. Unattended: yes.
- Harness gap: `AGENTS.md`: AGENTS.md and the implement-change skill say to run one test with `bin/rails test <file>`. On macOS this uses the first Ruby on PATH, which is the system Ruby 2.6, and it fails with a missing-bundler error. Only bin/harness picks a supported Ruby. The docs should say to put /opt/homebrew/opt/ruby/bin on PATH first (or use .tool-versions with a version manager), or bin/harness should offer a task that runs a single test.
- Harness gap: `AGENTS.md`: The task's criterion 'only files under test/ change' conflicts with the rule in AGENTS.md to add a docs/harness/log.md entry for each change. Nothing tells the agent which rule wins. I followed both and treated the log file as the allowed exception.
- Harness gap: `test/test_helper.rb`: Nothing in the harness docs lists the test base classes (Redmine::RoutingTest, Redmine::IntegrationTest) or the with_settings helper. I had to read test_helper.rb and existing tests to find them. A short section in docs/local-dev.md or the implement-change skill would help.

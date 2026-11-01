# Harness brief: repo

Written by uw-harness 0.3.0 on 2026-11-01 with claude. One page for the people who decide what comes next. It is rewritten on every run: do not edit it by hand.

## What changed

Harness coverage went from 19 to 92 out of 100, level 0 to 2 (self-checking). The coverage score measures structure: the files exist with real content, the commands resolve, the gates ran tests. It does not measure how good the docs or the tests are.

## What was checked by running it

| Gate | Command | Result | Tests |
| --- | --- | --- | --- |
| fast | `bin/harness check-fast` | pass | 3383 tests, 92 skipped |
| full | `bin/harness check` | pass | 6300 tests, 131 skipped |

Before the harness, the project's tests could not be measured: `bin/rails test` ran no test (exit 1). This says nothing about whether the tests pass, and the gates could not be compared with a starting point.
6 test files only compare literals (for example `assert True`) and protect nothing: `extra/sample_plugin/test/integration/routing_test.rb`, `test/helpers/activities_helper_test.rb`, `test/system/quick_jump_test.rb`, `test/system/responsive_menu_test.rb`, `test/unit/lib/redmine/notifiable_test.rb`.

The test counts come from the output of the gates on the machine that ran uw-harness. They become proof when CI runs `npx uw-harness verify` on every pull request.

## What is left out or weaker

- 1 changes outside the harness are in a separate commit that `git revert` drops: `Rakefile`.
- local-env: On a new SQLite3 database, bin/rails db:prepare fails every time at db/migrate/072_add_enumerations_position.rb (no such column: enumerations.position). The migration skips add_column when Enumeration.column_names already lists the column. bin/harness setup uses db:create db:migrate instead, which passes every time. The migration was not changed: a human should decide whether to fix it upstream.
- env-example: uw-harness flags db/migrate/001_setup.rb as a secret-looking value. It is the SHA1 hash of the default admin password 'admin', which doc/INSTALL documents and which Redmine forces users to change at first login. It is not a real secret, and the migration may not be changed, so this check stays partial.
- full-gate: Left out of bin/harness check: system tests (bin/harness test-system, need Chrome and a Mermaid.js download), the Bazaar non-ASCII test (needs the en_US.ISO8859-1 locale), bundle audit (needs network), and the PostgreSQL/MySQL and Ruby 3.3/3.4 matrix. The upstream workflows tests.yml and linters.yml still run all of them.
- ci: The uw-harness package is not published on npm (npx -y uw-harness returned 404 here), so the new harness.yml workflow will fail until it is published. The gates were checked with the local build of uw-harness (check passes) and run directly from a clean shell.
- deploy-explicit: Without human answers, docs/deploy.md and docs/observability.md keep open TODO blocks, so these two checks stay partial.

## Secret-looking values

4 files hold values that look like secrets. If they are real, a human must rotate them and remove them from the git history: `db/migrate/001_setup.rb` (password or secret), `test/functional/account_controller_test.rb` (password or secret), `test/integration/sessions_test.rb` (password or secret), `test/unit/lib/redmine/ciphering_test.rb` (password or secret).

## Open questions

| Question | Who can answer | Where |
| --- | --- | --- |
| Should changes from agents follow the upstream process (a patch attached to an issue on www.redmine.org, commit message ending with `(#issue)`) or a local branch and pull request process in this repository? | tech lead | `docs/agreements/working-agreements.md`, [guide](https://docs.unwritten.sh/harness/requirements/agreements/) |
| May the new workflow `.github/workflows/harness.yml` run on pull requests in this repository, given that upstream development happens in Subversion on www.redmine.org and GitHub pull requests are not reviewed there? | tech lead | `docs/agreements/working-agreements.md`, [guide](https://docs.unwritten.sh/harness/requirements/ci/) |
| Is this copy of Redmine deployed anywhere by your team (which server, which environments), or is it only a mirror of upstream used for development? | whoever deploys to production | `docs/deploy.md`, [guide](https://docs.unwritten.sh/harness/requirements/deploy-explicit/) |
| If this copy is deployed: who can deploy, how is a release built for it (git tag, archive, branch), and how do you roll back a release that ran database migrations? | whoever deploys to production | `docs/deploy.md`, [guide](https://docs.unwritten.sh/harness/requirements/deploy-explicit/) |
| Is it acceptable that the fast gate skips the SCM, LDAP and system (Chrome) tests that need external binaries or services? | tech lead | `docs/local-dev.md`, [guide](https://docs.unwritten.sh/harness/requirements/fast-gate/) |
| Which database should be the default for local development and the gates: SQLite3 (the current default of `bin/harness setup`) or PostgreSQL/MySQL in Docker? | tech lead | `docs/local-dev.md`, [guide](https://docs.unwritten.sh/harness/requirements/local-env/) |
| Where do production logs go (log/production.log, STDOUT to a collector?), and is there any error tracker, dashboard or alert channel for this instance? | whoever runs production | `docs/observability.md`, [guide](https://docs.unwritten.sh/harness/requirements/observability/) |

## The pilot task: Add a test for the /up health check route

config/routes.rb exposes GET /up (rails/health#show) for load balancers and uptime monitors, but no test in test/ covers it. Add a routing test and an integration test, so that a change to the routes or to authentication filters cannot break the health check without a failing test.

- Done when: A new routing assertion (for example in test/integration/routing/) checks that GET /up routes to rails/health#show.
- Done when: A new integration test checks that an anonymous GET /up returns 200, also when the setting 'login_required' is enabled.
- Done when: Only files under test/ change, `bin/harness check-fast` and `bin/harness check` pass, and a dated entry is added to docs/harness/log.md.

Run it with `npx uw-harness prove`: an agent does the task with the harness, on its own branch, and the result is added to this page.

## Pilot result: Add a test for the /up health check route

Run by claude on 2026-11-01, on branch `uw-harness/prove-20261101-1708`, in 5 minutes.

- Agent status: **done**. Acceptance criteria met, as reported by the agent: 3 of 3.
- Gates after the task: pass. Tests before: 6297 tests, 131 skipped. After: 6300 tests, 131 skipped.
- Fix rounds after a gate failed: 0. Questions only a human could answer: 0.
- Unattended (done, gates pass, every requested criterion met, no question for a human): **yes**.
  - met: A new routing assertion checks that GET /up routes to rails/health#show. test/integration/routing/health_test.rb RoutingHealthTest#test_health_check passes (bin/rails test test/integration/routing/health_test.rb).
  - met: A new integration test checks that an anonymous GET /up returns 200, also when 'login_required' is enabled. HealthTest#test_anonymous_get_up_should_return_200 and HealthTest#test_anonymous_get_up_should_return_200_when_login_is_required pass: 3 runs, 5 assertions, 0 failures for the two files.
  - met: Only files under test/ change, check-fast and check pass, and a dated entry is added to docs/harness/log.md. git status shows only the two new test files plus docs/harness/log.md, which this criterion requires. bin/harness check-fast: 1101 files inspected, no offenses; 3383 runs, 0 failures, 0 errors, 92 skips. bin/harness check: 6299 runs, 0 failures, 0 errors, 131 skips; autoload test 1 run, 0 failures.

Gaps in the harness that the agent reported:

- `AGENTS.md`: AGENTS.md and the implement-change skill say to run one test with `bin/rails test <file>`. On macOS this uses the first Ruby on PATH, which is the system Ruby 2.6, and it fails with a missing-bundler error. Only bin/harness picks a supported Ruby. The docs should say to put /opt/homebrew/opt/ruby/bin on PATH first (or use .tool-versions with a version manager), or bin/harness should offer a task that runs a single test.
- `AGENTS.md`: The task's criterion 'only files under test/ change' conflicts with the rule in AGENTS.md to add a docs/harness/log.md entry for each change. Nothing tells the agent which rule wins. I followed both and treated the log file as the allowed exception.
- `test/test_helper.rb`: Nothing in the harness docs lists the test base classes (Redmine::RoutingTest, Redmine::IntegrationTest) or the with_settings helper. I had to read test_helper.rb and existing tests to find them. A short section in docs/local-dev.md or the implement-change skill would help.

## What this does not prove

It does not prove that agents can work on this repository without supervision. It proves that the knowledge is written down and that the gates run and run tests. One real task went through without help from a human, as reported above. One task is one data point. Review the branch, answer the open questions, and judge the result yourself.

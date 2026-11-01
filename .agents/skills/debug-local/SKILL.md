---
name: debug-local
description: Use when a Redmine test fails, a page errors, or behavior is wrong on your machine and you need to reproduce and find the cause.
---

# Debug locally

1. Reproduce with the smallest command. For a test: `bin/rails test test/functional/issues_controller_test.rb -n test_show` with `PARALLEL_WORKERS=1` so that output and breakpoints stay in one process. For a page: `bin/harness dev`, then open http://localhost:3000 (login `admin`).
2. Read the logs: `log/test.log` for tests, `log/development.log` for the server. The level is `debug` outside production, so SQL queries and parameters are there. `tail -f log/development.log` while you click.
3. Stop in the code: add `debugger` (the `debug` gem is in the development and test groups), then run the single test or the server again. Remove it before you commit.
4. Inspect data: `bin/rails console` (development database) or `bin/rails console -e test`. In tests, data comes from `test/fixtures/*.yml`; check which fixtures the test class loads (`fixtures :projects, :issues, ...`).
5. Check the environment when tests skip or fail around SCM, LDAP or images: `Subversion test repository NOT FOUND` means `tmp/test` is empty or `svnadmin` is missing (run `bin/harness setup`); `Skipping LDAP tests` is expected without an LDAP server; Admin > Information (`/admin/info`) lists missing ImageMagick, Ghostscript, Pandoc or Mermaid.
6. If the failure only happens in the full suite, look for order dependence: rerun with the seed that the output printed, `bin/rails test test/unit --seed 12345`.
7. If boot fails, move any folder out of `plugins/` and retry; plugin Gemfiles and code load at boot.
8. Once fixed, run `bin/harness check-fast` and write down anything surprising in `docs/harness/log.md`.

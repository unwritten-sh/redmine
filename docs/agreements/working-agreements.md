# Working agreements

[CONTRIBUTING.md](../../CONTRIBUTING.md) is the upstream rule: contributions go to the issue tracker on www.redmine.org, not to GitHub pull requests. This file adds what the git history shows and the rules for this copy of the repository.

## What the history shows

- The git repository is a mirror of the official Subversion repository. Development happens on `trunk`, which is `master` here. Stable branches are named `X.Y-stable` (for example `6.0-stable`).
- Fixes move between trunk and stable branches as merges with the message `Merged rNNNNN from trunk to X.Y-stable (#NNNNN).`
- Commit messages are one sentence in the imperative mood, ending with the redmine.org issue number in parentheses and a period. Examples from `git log`:
  - `Fix missing Gantt expanders for projects with only subprojects (#44694).`
  - `Include seconds in pasted image filenames (#44642).`
- A commit that refers to an earlier commit cites its Subversion revision: `... no longer used since r25360 (#44689).`

## Rules for agents and humans

- Never push to `master` or to a `X.Y-stable` branch. Work on a branch; a human reviews every change.
- Follow the upstream commit style above. When there is no redmine.org issue, write the sentence without the number.
- Do not edit upstream files only for local needs (`doc/*`, `README.rdoc`, `CONTRIBUTING.md`, `.github/workflows/tests.yml`, `.github/workflows/linters.yml`). Add new files next to them.

> [!WARNING]
> **Needs a human.** Should changes from agents follow the upstream process (a patch attached to an issue on www.redmine.org, commit message ending with `(#issue)`) or a local branch and pull request process in this repository?
> Why it matters and how to do it: https://docs.unwritten.sh/harness/requirements/agreements/
<!-- uw-harness:todo agreements -->

> [!WARNING]
> **Needs a human.** May the new workflow `.github/workflows/harness.yml` run on pull requests in this repository, given that upstream development happens in Subversion on www.redmine.org and GitHub pull requests are not reviewed there?
> Why it matters and how to do it: https://docs.unwritten.sh/harness/requirements/ci/
<!-- uw-harness:todo ci -->

## Definition of done

A change is done when:

1. `bin/harness check-fast` passes (RuboCop, Stylelint, unit and helper tests).
2. `bin/harness check` passes when the change touches controllers, views, routes, the API, or anything outside `app/models` and `lib/`.
3. New behavior has a test in `test/` (unit, functional, integration or system), with fixtures in `test/fixtures` when needed.
4. A migration works on SQLite3, PostgreSQL and MySQL (see [0002](../decisions/0002-multi-database-support-via-database-yml.md)).
5. User-visible strings are in `config/locales/en.yml` (other locales are updated by `bin/rails locales:update`).
6. A significant change has a dated entry in [docs/harness/log.md](../harness/log.md).

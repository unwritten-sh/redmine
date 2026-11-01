# Deploy

Redmine is a product that organizations install on their own servers. The repository has no Dockerfile, Procfile, Capistrano file, Helm chart or deploy workflow. The generic procedure is in `doc/INSTALL` (new installation) and `doc/UPGRADING` (upgrade). This page summarizes it and lists what the repository does not say about this copy.

> [!WARNING]
> **Needs a human.** Is this copy of Redmine deployed anywhere by your team (which server, which environments), or is it only a mirror of upstream used for development?
> Why it matters and how to do it: https://docs.unwritten.sh/harness/guides/deploy/
<!-- uw-harness:todo deploy-explicit -->

## Environments

The code knows three Rails environments: `development`, `test` and `production` (`config/environments/`). Production settings that the code reads are in `config/database.yml`, `config/configuration.yml` and `config/additional_environment.rb`, all ignored by git and created from their `.example` files. No staging or production host is named in the repository.

## How a release is built

Upstream releases are source archives and tags (see `doc/CHANGELOG`). There is no build artifact: the server runs the source tree. On the server, the steps from `doc/INSTALL` are:

1. Write `config/database.yml` for the production database.
2. `bundle install --without development test` (installs the adapter gem named in `config/database.yml`).
3. `bin/rails generate_secret_token` (writes `config/initializers/secret_token.rb`).
4. Optional: `bin/rails redmine:mermaid:install RAILS_ENV="production"` (downloads Mermaid.js from registry.npmjs.org).
5. Optional: `bin/rails assets:precompile RAILS_ENV="production"`.

## How it is deployed

1. `bin/rails db:migrate RAILS_ENV="production"`, and `bin/rails redmine:plugins:migrate RAILS_ENV="production"` when plugins are installed.
2. On a new installation only: `bin/rails redmine:load_default_data RAILS_ENV="production"`.
3. Give the application user write access to `files/`, `log/`, `tmp/` and `public/assets` (see `doc/INSTALL`, step 9).
4. After an upgrade: `bin/rails tmp:cache:clear tmp:sessions:clear`, then restart the application server.
5. Start the server, for example `bin/rails server -e production` (Puma), or behind Passenger or another Rack server.

For an upgrade, `doc/UPGRADING` adds: copy `config/database.yml`, `config/configuration.yml`, the `files/` folder and the `plugins/` and `themes/` folders from the old installation.

> [!WARNING]
> **Needs a human.** If this copy is deployed: who can deploy, how is a release built for it (git tag, archive, branch), and how do you roll back a release that ran database migrations?
> Why it matters and how to do it: https://docs.unwritten.sh/harness/guides/deploy/
<!-- uw-harness:todo deploy-explicit -->

## How to roll back

The repository shows only the generic Rails mechanism: `bin/rails db:rollback RAILS_ENV="production" STEP=n` reverts migrations, then the previous source tree is put back. Not every migration is reversible, so a database backup before `db:migrate` is the safe path. The rollback procedure for this copy is one of the questions above.

## What to check after a deploy

- `GET /up` answers 200 (Rails health check, `config/routes.rb`).
- Admin > Information (`/admin/info`) shows all migrations run, `files/` writable, the default admin password changed, and, in production, a warning when the ActiveJob queue adapter is still `:async`.
- `log/production.log` (or STDOUT when `RAILS_LOG_TO_STDOUT` is set) has no errors. See [observability.md](observability.md).

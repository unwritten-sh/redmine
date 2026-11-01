# Observability

This page lists what the code provides to watch a running Redmine. The repository has no error tracker (Sentry or similar), no metrics library and no tracing in the `Gemfile`. Where the logs of a production instance go is not visible here.

## Logs

- Library: the Rails logger (`ActiveSupport::Logger`).
- Level: `info` in production, `debug` elsewhere (`config/application.rb`).
- Destination: `log/<environment>.log` by default. In production, setting `RAILS_LOG_TO_STDOUT` sends logs to STDOUT with `ActiveSupport::TaggedLogging` (`config/environments/production.rb`). `config/additional_environment.rb` can set another logger, for example syslog (commented example in `production.rb`).
- Mail delivery is not logged in production (`config.action_mailer.logger = nil`).
- `ApplicationController` logs invalid authenticity tokens and invalid query statements at `error` level (`app/controllers/application_controller.rb`).

## Health and status

- `GET /up`: Rails health check (`rails/health#show`, `config/routes.rb`). It returns 200 when the app boots without exceptions and 500 otherwise. It does not check the database.
- Admin > Information (`/admin/info`, `AdminController#info`): checklist with default admin password changed, `files/` writable, pending migrations, ImageMagick, Ghostscript, Pandoc and Mermaid availability, and in production a warning when the ActiveJob queue adapter is `:async`.
- Background jobs: `WebhookJob` delivers webhooks. Without a queue adapter configured, jobs run in threads of the web process and are lost on restart.

## How to tell that something is wrong

1. `GET /up` does not answer 200.
2. `log/production.log` (or the STDOUT stream) shows `FATAL` or `ERROR` lines, or 500 responses (`Completed 500`).
3. Admin > Information shows a red item, for example pending migrations after an upgrade.
4. Users report that email notifications, incoming email or repository updates stopped: those depend on SMTP, on the cron jobs for `redmine:email:receive_imap` or `redmine:fetch_changesets`, and on the SCM binaries, which run outside the web process.

> [!WARNING]
> **Needs a human.** Where do production logs go (log/production.log, STDOUT to a collector?), and is there any error tracker, dashboard or alert channel for this instance?
> Why it matters and how to do it: https://docs.unwritten.sh/harness/guides/observability/
<!-- uw-harness:todo observability -->

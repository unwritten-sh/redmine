# Product

Redmine is a flexible, open-source project management web application built with Ruby on Rails. It gives teams one self-hosted place to manage many projects: issues with configurable trackers and workflows, time tracking, Gantt charts and calendars, wikis, forums, documents, files and source repository browsing. Organizations host it on their own servers, choose their database, add plugins and themes, and connect other systems through the REST API, OAuth2, incoming email and webhooks.

This repository is a git mirror of the official Subversion repository (commit messages cite `rNNNNN` revisions and `#NNNNN` issues on www.redmine.org). See [CONTRIBUTING.md](../CONTRIBUTING.md).

## Users

- **Project members** (developers, reporters): create and update issues, log time, edit wiki pages.
- **Project managers**: plan versions, read Gantt charts and calendars, run reports.
- **Administrators**: configure trackers, roles, workflows, custom fields, authentication (LDAP, two-factor) and global settings.
- **API clients and integrators**: use the REST API, OAuth2 applications and webhooks.
- **Mail servers and SCM servers**: push email and repository changes into Redmine (`rdm-mailhandler`, `reposman`, the sys API).
- **Plugin and theme developers**: extend Redmine.

## Main use cases

| Use case | What it does | Entry points |
| --- | --- | --- |
| Issue tracking | Create, list, filter, edit and bulk-update issues with trackers, statuses, workflows, custom fields, watchers, relations and journals. | `app/controllers/issues_controller.rb`, `app/models/issue.rb`, `app/models/issue_query.rb`, `app/controllers/workflows_controller.rb` |
| Time tracking | Log spent time on issues and projects, report on it. | `app/controllers/timelog_controller.rb`, `app/models/time_entry.rb`, `app/models/time_entry_query.rb` |
| Planning | Versions and roadmap, Gantt charts (HTML, PDF, PNG), calendars. | `app/controllers/gantts_controller.rb`, `app/controllers/calendars_controller.rb`, `app/controllers/versions_controller.rb`, `lib/redmine/helpers/` |
| Collaboration | Per-project wikis (Textile or CommonMark, Mermaid diagrams), forums, news, documents, files. | `app/controllers/wiki_controller.rb`, `boards_controller.rb`, `messages_controller.rb`, `news_controller.rb`, `documents_controller.rb`, `lib/redmine/wiki_formatting/` |
| Source repositories | Browse Subversion, Git, Mercurial, Bazaar, CVS and filesystem repositories, link changesets to issues. | `app/controllers/repositories_controller.rb`, `app/models/repository/`, `lib/redmine/scm/adapters/`, `app/controllers/sys_controller.rb`, `extra/svn/reposman.rb` |
| Administration and access control | Projects, users, groups, roles, permissions, custom fields, enumerations, LDAP, two-factor auth, settings. | `app/controllers/admin_controller.rb`, `projects_controller.rb`, `users_controller.rb`, `roles_controller.rb`, `settings_controller.rb`, `twofa_controller.rb`, `lib/redmine/access_control.rb` |
| Incoming email | Create and update issues and messages from email (HTTP endpoint, IMAP or POP3). | `app/controllers/mail_handler_controller.rb`, `app/models/mail_handler.rb`, `extra/mail_handler/rdm-mailhandler.rb`, `lib/tasks/email.rake` |
| REST API, OAuth2, webhooks | XML/JSON API with API key or OAuth2 (Doorkeeper), outgoing webhooks sent by a background job. | `app/views/**/*.api.rsb`, `app/controllers/oauth2_applications_controller.rb`, `config/initializers/doorkeeper.rb`, `app/controllers/webhooks_controller.rb`, `app/jobs/webhook_job.rb` |
| Imports and exports | Import issues, time entries, users and non-working dates from CSV. Export to CSV, PDF and Atom. | `app/controllers/imports_controller.rb`, `app/models/issue_import.rb`, `lib/redmine/export/` |
| Plugins and themes | Extensions in `plugins/` and `themes/`, loaded at boot. | `lib/redmine/plugin.rb`, `lib/redmine/plugin_loader.rb`, `config/initializers/00-core_plugins.rb`, `extra/sample_plugin/`, `lib/redmine/themes.rb` |

All routes are in `config/routes.rb`.

## Glossary

- **Tracker**: issue type (for example Bug, Feature, Support). Each tracker has its own workflow and fields (`app/models/tracker.rb`).
- **Journal / JournalDetail**: history entry of an issue or other object: the notes and the list of attribute changes (`app/models/journal.rb`).
- **Workflow**: rules that say which role may move an issue from one status to another, and which fields are read-only or required (`workflow_transition.rb`, `workflow_permission.rb`).
- **Enumeration**: admin-defined value lists: issue priorities, time entry activities, document categories.
- **Principal**: base class of User and Group (`app/models/principal.rb`).
- **Member / MemberRole**: membership of a user or group in a project, with one or more roles.
- **Version**: project milestone or release, used for the roadmap.
- **Changeset**: a commit imported from a linked source repository.
- **Query**: saved filter and column set for issues, time entries, projects or users (`app/models/query.rb`).
- **Auth source**: external authentication backend, currently LDAP (`auth_source_ldap.rb`).
- **Sys API**: endpoints under `/sys` used by SCM servers and `reposman.rb` to create repositories and fetch changesets.
- **Redmine.pm**: Perl Apache module in `extra/svn` for repository access control against Redmine users.
- **Textile / CommonMark**: the two text formatters for wiki pages and descriptions (`lib/redmine/wiki_formatting`).
- **Sudo mode**: the user enters the password again before sensitive actions (`lib/redmine/sudo_mode.rb`).
- **Fixtures**: YAML test data in `test/fixtures`, loaded by the Rails tests.
- **rNNNNN**: Subversion revision number cited in commit messages.
- **#NNNNN**: issue number on www.redmine.org, cited at the end of each commit message.

# 0003. Serve JavaScript with importmap and Stimulus, without a build step

- Status: inferred from the code, to be confirmed by the team
- Date: 2026-11-01

## Context

Administrators install Redmine from a source archive (`doc/INSTALL`). A Node.js build step would add a toolchain to every installation.

## Decision

JavaScript is written as Stimulus controllers in `app/javascript/controllers` and served as ES modules through `importmap-rails` (`config/importmap.rb`) and Propshaft. Third-party modules are vendored in `vendor/javascript`. Node.js is used only in development, for Stylelint (`package.json`).

## Consequences

- No bundler, transpiler or `node_modules` is needed in production.
- New JavaScript must be plain browser-ready ES modules.
- Large optional libraries are installed on demand, for example Mermaid.js with `bin/rails redmine:mermaid:install`.

---
name: frontend-stimulus
description: Use when a Redmine change touches JavaScript, CSS, icons or view templates (Stimulus controllers, importmap, stylesheets, SVG sprite).
---

# Change the frontend

1. Find the existing piece. JavaScript lives in `app/javascript/controllers/*_controller.js` (Stimulus) and `app/javascript/wiki_formatting/`. Pins are in `config/importmap.rb`; `pin_all_from "app/javascript/controllers"` loads every controller, so a new file `foo_bar_controller.js` is available as `data-controller="foo-bar"` without other changes. Older code still uses jQuery in `app/assets/javascripts`.
2. There is no JavaScript build: write browser-ready ES modules, no TypeScript or JSX (see `docs/decisions/0003-importmap-stimulus-without-js-build.md`). Third-party modules are vendored in `vendor/javascript` and pinned with `bin/importmap pin <package>`.
3. Wire the controller in the ERB view (`app/views/**`) or helper with `data-controller`, `data-action` and `data-<name>-target` attributes. Follow an existing controller, for example `clipboard_controller.js` and its use in `app/helpers/application_helper.rb` (`data: {controller: 'clipboard', action: 'clipboard#copyText'}`).
4. Styles go in `app/assets/stylesheets/application.css` (or the matching file such as `gantt.css`, `responsive.css`). Colors come from `open-color.css` variables. Check right-to-left and small screens (`responsive.css`).
5. Icons: use the `sprite_icon('name', label)` helper (`app/helpers/icons_helper.rb`). Icon names map to Tabler icons in `config/icon_source.yml`; after adding one, regenerate `app/assets/images/icons.svg` with `bin/rails icons:generate` (needs network).
6. Strings shown to users go in `config/locales/en.yml` and are passed to JavaScript through data attributes or the view, not hard-coded in JavaScript.
7. Lint: `bin/harness lint` (RuboCop and Stylelint with `.stylelintrc`).
8. Test the behavior in a system test in `test/system/` (Capybara and Selenium): `bin/rails test test/system/copy_to_clipboard_test.rb`, or all of them with `bin/harness test-system`. They need Google Chrome; set `GOOGLE_CHROME_OPTS_ARGS=headless` to hide the browser. Mermaid tests also need `bin/rails redmine:mermaid:install RAILS_ENV=test`.
9. Finish with `bin/harness check-fast`.

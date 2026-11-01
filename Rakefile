#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

RedmineApp::Application.load_tasks

# Harness tasks: one entry point for agents and humans (see AGENTS.md).
# Run them with `bin/harness <task>` (it picks a supported Ruby and installs
# gems for `setup`) or with `bundle exec rake <task>` once gems are installed.
module HarnessTasks
  RAILS = [Gem.ruby, 'bin/rails'].freeze
  STYLELINT = 'node_modules/.bin/stylelint'
  # Test repositories that only need tar, and the binary that the others need.
  SCM_TARBALLS = %w(git git_utf8 filesystem bazaar cvs).freeze
  SCM_BINARIES = {'subversion' => 'svnadmin', 'mercurial' => 'hg'}.freeze

  module_function

  def test_env
    {'RAILS_ENV' => 'test', 'PARALLEL_WORKERS' => ENV.fetch('PARALLEL_WORKERS', Etc.nprocessors.to_s)}
  end

  def binary?(name)
    ENV['PATH'].to_s.split(File::PATH_SEPARATOR).any? {|dir| File.executable?(File.join(dir, name))}
  end
end

desc 'List the harness tasks'
task :help => :environment do
  puts 'Harness tasks (run with bin/harness <task> or bundle exec rake <task>):'
  puts <<~HELP
    setup        Install gems and Node packages, prepare the SQLite3 databases, test repositories and git hooks
    dev          Start the development server on http://localhost:3000
    test         Run all tests except system tests (bin/rails test)
    lint         RuboCop and Stylelint
    check-fast   Fast gate: lint, then unit and helper tests (run before every push)
    check        Full gate: lint, all tests except system tests, plugin autoload tests
    test-system  System tests (need Google Chrome)
  HELP
end

desc 'Prepare the development and test databases (SQLite3 by default), test repositories and git hooks'
task :setup => :environment do
  # Not db:prepare: on a new database it fails at migration 072 (see docs/harness/log.md).
  sh(*HarnessTasks::RAILS, 'db:create', 'db:migrate')
  sh({'REDMINE_LANG' => 'en'}, *HarnessTasks::RAILS, 'redmine:load_default_data')
  sh({'RAILS_ENV' => 'test'}, *HarnessTasks::RAILS, 'db:create', 'db:migrate', 'db:environment:set')
  scms = HarnessTasks::SCM_TARBALLS +
         HarnessTasks::SCM_BINARIES.select {|_, bin| HarnessTasks.binary?(bin)}.keys
  scm_tasks = scms.map {|scm| "test:scm:setup:#{scm}"}
  sh({'RAILS_ENV' => 'test'}, *HarnessTasks::RAILS, *scm_tasks, 'test:scm:update')
  if system('git', 'config', 'core.hooksPath', '.githooks')
    puts 'Git hooks: .githooks/pre-push runs the fast gate.'
  else
    warn 'Could not set core.hooksPath; run: git config core.hooksPath .githooks'
  end
end

desc 'Start the development server on http://localhost:3000'
task :dev => :environment do
  sh(*HarnessTasks::RAILS, 'server')
end

desc 'Lint Ruby (RuboCop) and CSS (Stylelint)'
task :lint => :environment do
  sh(Gem.ruby, '-S', 'bundle', 'exec', 'rubocop', '--parallel')
  if File.exist?(HarnessTasks::STYLELINT)
    sh(HarnessTasks::STYLELINT, 'app/assets/stylesheets/**/*.css')
  else
    warn 'Stylelint is not installed (run bin/harness setup); CSS lint skipped.'
  end
end

desc 'Fast gate: lint, then unit and helper tests'
task 'check-fast' => :lint do
  sh(HarnessTasks.test_env, *HarnessTasks::RAILS, 'test', 'test/unit', 'test/helpers')
end

desc 'Full gate: lint, all tests except system tests, plugin autoload tests'
task :check => :lint do
  sh(HarnessTasks.test_env, *HarnessTasks::RAILS, 'test')
  sh({'RAILS_ENV' => 'test'}, *HarnessTasks::RAILS, 'test:autoload')
end

desc 'System tests (need Google Chrome; set GOOGLE_CHROME_OPTS_ARGS=headless for CI-like runs)'
task 'test-system' => :environment do
  sh({'RAILS_ENV' => 'test'}, *HarnessTasks::RAILS, 'test:system')
end

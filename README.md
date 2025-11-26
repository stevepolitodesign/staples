# Staples

[![Ruby](https://github.com/stevepolitodesign/staples/actions/workflows/main.yml/badge.svg)](https://github.com/stevepolitodesign/staples/actions/workflows/main.yml)

The basic ingredients for your next Rails project.

## Why Staples?

Templates like [JumpStart][jumpstart] or [Bullet Train][bullettrain] are intended to be used for rapidly building SaaS applications.

Staples makes no assumptions about your project. Instead, it's intended to be a starting off point for any and all new projects.

[jumpstart]: https://jumpstartrails.com
[bullettrain]: https://bullettrain.co

## Installation

Install the gem by executing:

```bash
gem install staples
```

## Requirements

Staples requires the latest version of [Rails][rails] and its dependencies.

Additionally, Staples requires [yarn][yarn], [PostgreSQL][postgresql] and
[Redis][redis].

[rails]: https://guides.rubyonrails.org/install_ruby_on_rails.html
[yarn]: https://yarnpkg.com/getting-started/install
[postgresql]: https://formulae.brew.sh/formula/postgresql@17
[redis]: https://formulae.brew.sh/formula/redis

## Usage

```
staples <app_name>
```

## Environment Variables

Staples configures your application to use the following environment variables in production:

- `DATABASE_URL` - PostgreSQL database connection string (required)
- `APPLICATION_HOST` - The domain where your application is hosted (required, used for mailer URL generation)
- `ASSET_HOST` - CDN or asset host URL (optional, for serving static assets)
- `MAILER_SENDER` - Default email address for outgoing emails (defaults to `contact@example.com`)
- `RAILS_MASTER_KEY` - Required for decrypting credentials (automatically set in CI)

## Deploying to Heroku

Staples is optimized for Heroku. As such, you'll want to be sure to add the required buildpacks, addons and environment variables.

```
heroku apps:create

heroku buildpacks:set heroku/nodejs
heroku buildpacks:set heroku/ruby

heroku addons:create heroku-postgresql:essential-0
heroku addons:create heroku-redis:mini
heroku config:set \
  APPLICATION_HOST=value-from-heroku
  RAILS_MASTER_KEY=value-from-config/master.key
```

## GitHub Actions

Because Staples sets `config.require_master_key = true`, you'll need to set this value in GitHub in order for GitHub Actions to work.

```
gh variable set RAILS_MASTER_KEY < config/master.key
```

## Features

### Authentication

Staples ships with a `user` model via [Devise][devise]. We prefer Devise over the [authentication generator][auth-generator] because...

- It receives frequent security updates, whereas you're on your own with a generator.
- It's widely adopted in the Rails community.
- It has a [rich ecosystem][ecosystem].

Additionally, the following modules are enabled:

- [Database Authenticatable][database-authenticatable]
- [Registerable][registerable]
- [Recoverable][recoverable]
- [Rememberable][rememberable]
- [Validatable][validatable]
- [Trackable][trackable]

[database-authenticatable]: https://www.rubydoc.info/gems/devise/Devise/Models/DatabaseAuthenticatable
[registerable]: https://www.rubydoc.info/gems/devise/Devise/Models/Registerable
[recoverable]: https://www.rubydoc.info/gems/devise/Devise/Models/Recoverable
[rememberable]: https://www.rubydoc.info/gems/devise/Devise/Models/Rememberable
[validatable]: https://www.rubydoc.info/gems/devise/Devise/Models/Validatable
[trackable]: https://www.rubydoc.info/gems/devise/Devise/Models/Trackable
[devise]: https://github.com/heartcombo/devise
[auth-generator]: https://guides.rubyonrails.org/security.html#authentication
[ecosystem]: https://github.com/heartcombo/devise?tab=readme-ov-file#extensions

### Organizations

Staples draws inspiration from [Laravel][laravel], [JumpStart][jumpstart], and [Bullet Train][bullettrain] by introducing the concept of "Teams" in an effort to make your application more resilient from day 0.

When a `user` is created, we automatically create an `organization`, and associate the two via a `membership`.

[laravel]: https://jetstream.laravel.com/features/teams.html
[jumpstart]: https://jumpstartrails.com/docs/accounts
[bullettrain]: https://blog.bullettrain.co/teams-should-be-an-mvp-feature/

### Frontend

Staples proudly ships with [Bootstrap][bootstrap] as its frontend toolkit.

Bootstrap is mature, battle tested, and well documented. It's basically the Rails of frontend toolkits for server-rendered applications. It gives you everything you need, (including a rich set of [JavaScript plugins][bootstrap-js]), and is [meant to be customized][bootstrap-customize].

[bootstrap]: https://getbootstrap.com
[bootstrap-js]: https://getbootstrap.com/docs/5.3/getting-started/javascript/
[bootstrap-customize]: https://getbootstrap.com/docs/5.3/customize/overview/

### Background Jobs

Staples ships with [Sidekiq][sidekiq] instead of [Solid Queue][solid-queue] simply because there's an [open issue][solid-queue-issue] with Solid Queue and Heroku.

[sidekiq]: https://github.com/sidekiq/sidekiq
[solid-queue]: https://github.com/rails/solid_queue/
[solid-queue-issue]: https://github.com/rails/solid_queue/issues/330

### Configuration

#### Application

The following configurations are applied to all environments:

- `config.active_job.queue_adapter = :sidekiq` - Uses Sidekiq for background job processing
- `config.active_record.strict_loading_by_default = true` - Enables strict loading to prevent N+1 queries
- `config.active_record.strict_loading_mode = :n_plus_one_only` - Strict loading only raises errors for N+1 queries
- `config.require_master_key = true` - Requires the master key to be present for encrypted credentials

#### Production

- `config.sandbox_by_default = true` - Database sessions are sandboxed by default in console
- `config.active_record.action_on_strict_loading_violation = :log` - Logs strict loading violations instead of raising errors
- `config.asset_host = ENV["ASSET_HOST"]` - Configures asset host from environment variable
- `config.action_mailer.default_url_options = { host: ENV.fetch("APPLICATION_HOST") }` - Sets mailer host from environment variable

#### Development

- `config.active_model.i18n_customize_full_message = true` - Customizes full error messages for internationalization
- `config.i18n.raise_on_missing_translations = true` - Raises errors when translations are missing
- `config.generators.apply_rubocop_autocorrect_after_generate! = true` - Automatically runs RuboCop autocorrect after generating files

#### Test

- `config.action_dispatch.show_exceptions = :none` - Disables exception pages to allow errors to propagate in tests
- `config.action_mailer.default_url_options = { host: "localhost", port: 3001 }` - Sets mailer host for test environment
- `config.i18n.raise_on_missing_translations = true` - Raises errors when translations are missing
- `config.active_job.queue_adapter = :inline` - Executes background jobs synchronously in tests

### Views

Staples includes several view enhancements.

#### Application Layout

The HTML tag includes a `lang` attribute set to the current locale (`<html lang="<%= I18n.locale %>">`), which improves accessibility and SEO.

#### Partials

Staples provides reusable partials to handle common UI patterns:

- **Flash messages** (`app/views/application/_flashes.html.erb`) - Displays Bootstrap-styled flash messages for notices, alerts, and other feedback
- **Form error messages** (`app/views/application/_error_messages.html.erb`) - Consistently displays validation errors across forms
- **Navigation** (`app/views/application/_nav.html.erb`) - A Bootstrap navbar with authentication-aware links
- **Card component** (`app/views/application/_card.html.erb`) - A reusable card component for consistent layout

#### Devise Views

Custom Devise views are included for all authentication flows (sign up, sign in, password recovery, account editing) with Bootstrap styling applied.

### Test Suite

Staples includes a comprehensive test suite built on Rails' default testing framework with additional tools for better test coverage and maintainability.

#### Testing Gems

The following gems are included to enhance the testing experience:

- [Factory Bot][factory-bot] - Provides factories for test data instead of fixtures
- [Capybara Email][capybara-email] - Adds email testing capabilities to system tests
- [Capybara Accessibility Audit][capybara-accessibility] - Automatically audits accessibility in system tests

[factory-bot]: https://github.com/thoughtbot/factory_bot_rails
[capybara-email]: https://github.com/dockyard/capybara-email
[capybara-accessibility]: https://github.com/thoughtbot/capybara_accessibility_audit

#### Test Helpers

Staples configures the test suite with helpful integrations:

- Devise test helpers are included in all tests via `Devise::Test::IntegrationHelpers`
- Factory Bot syntax methods are available throughout the test suite
- Capybara is configured to run on port 3001 in order to work with Capybara Email.
- A `sign_in_as(user)` helper method is added to `ApplicationSystemTestCase` for easy authentication in system tests

#### Included Tests

The following test files are generated to provide examples and coverage for core functionality:

- Model tests for `User`, `Organization`, and `Membership`
- Controller tests for Devise registrations
- System tests for authentication flows
- Factory definitions for all core models

### Strong Migrations

Staples ships with [Strong Migrations][strong-migrations] in order to catch unsafe migrations in development.

[strong-migrations]: https://github.com/ankane/strong_migrations

### Static Pages

Staples ships with [High Voltage][high-voltage] to easily include static pages.

[high-voltage]: https://github.com/thoughtbot/high_voltage

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. From there, you can run `staples <app_name>` to test the current code.

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org][rubygems].

[rubygems]: https://rubygems.org

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stevepolitodesign/staples. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct][coc].

## License

The gem is available as open source under the terms of the [MIT License][mit].

## Code of Conduct

Everyone interacting in the Staples project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct][coc].

[coc]: https://github.com/stevepolitodesign/staples/blob/main/CODE_OF_CONDUCT.md
[mit]: https://opensource.org/licenses/MIT

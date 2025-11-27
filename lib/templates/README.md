# README

## Environment Variables

- `DATABASE_URL` - PostgreSQL database connection string (required)
- `APPLICATION_HOST` - The domain where your application is hosted (required, used for mailer URL generation)
- `ASSET_HOST` - CDN or asset host URL (optional, for serving static assets)
- `MAILER_SENDER` - Default email address for outgoing emails (defaults to `contact@example.com`)
- `RAILS_MASTER_KEY` - Required for decrypting credentials (automatically set in CI)

## Features

### Authentication

This application ships with a `user` model via [Devise][devise]. We prefer Devise over the [authentication generator][auth-generator] because...

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

This application draws inspiration from [Laravel][laravel], [JumpStart][jumpstart], and [Bullet Train][bullettrain] by introducing the concept of "Teams" in an effort to make your application more resilient from day 0.

When a `user` is created, we automatically create an `organization`, and associate the two via a `membership`.

[laravel]: https://jetstream.laravel.com/features/teams.html
[jumpstart]: https://jumpstartrails.com/docs/accounts
[bullettrain]: https://blog.bullettrain.co/teams-should-be-an-mvp-feature/

### Frontend

This application proudly ships with [Bootstrap][bootstrap] as its frontend toolkit.

Bootstrap is mature, battle tested, and well documented. It's basically the Rails of frontend toolkits for server-rendered applications. It gives you everything you need, (including a rich set of [JavaScript plugins][bootstrap-js]), and is [meant to be customized][bootstrap-customize].

[bootstrap]: https://getbootstrap.com
[bootstrap-js]: https://getbootstrap.com/docs/5.3/getting-started/javascript/
[bootstrap-customize]: https://getbootstrap.com/docs/5.3/customize/overview/

### Background Jobs

This application ships with [Sidekiq][sidekiq] instead of [Solid Queue][solid-queue] simply because there's an [open issue][solid-queue-issue] with Solid Queue and Heroku.

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

### Strong Migrations

This application ships with [Strong Migrations][strong-migrations] in order to catch unsafe migrations in development.

[strong-migrations]: https://github.com/ankane/strong_migrations

### Static Pages

This application ships with [High Voltage][high-voltage] to easily include static pages.

[high-voltage]: https://github.com/thoughtbot/high_voltage

### Development Seeds

This application provides a custom seeder task specifically for development and staging environments. Unlike `db/seeds.rb` which runs in all environments, the development seeder is isolated to local development.

The seeder is implemented in `lib/development/seeder.rb` and can be run with:

```bash
rake development:db:seed
```

For a complete reset, use the replant task which truncates all tables before seeding:

```bash
rake development:db:seed:replant
```

**Important**: The development seeder should be idempotent, meaning it can be run multiple times without creating duplicate data or errors.

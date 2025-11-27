def source_paths
  Array(super) + [__dir__]
end

def install_gems
  gem "active_link_to"
  gem "devise", github: "heartcombo/devise"
  gem "high_voltage"
  gem "sidekiq"
  gem "strong_migrations"

  gem_group :development, :test do
    gem "capybara-email"
    gem "factory_bot_rails"
  end

  gem_group :test do
    gem "capybara_accessibility_audit"
  end
end

install_gems

after_bundle do
  # Generators
  generate_devise
  generate_strong_migrations

  # Initializers & Configuration
  configure_environments
  configure_database
  add_high_voltage_initializer
  add_sidekiq_initializer

  # CI
  configure_ci

  # Database
  add_migrations

  # Deployment
  add_procfiles

  # Application Code
  add_application_code
  configure_routes
  add_rake_tasks

  # Test Suite
  add_test_suite

  # Assets
  configure_sass

  # Finalization
  run_migrations
  update_readme
  lint_codebase

  print_message
end

def generate_devise
  rails_command "generate devise:install"
  gsub_file "config/initializers/devise.rb", /config\.mailer_sender = ['"]please-change-me-at-config-initializers-devise@example\.com['"]/, 'config.mailer_sender = ENV.fetch("MAILER_SENDER", "contact@example.com")'
end

def generate_strong_migrations
  rails_command "generate strong_migrations:install"
end

def configure_ci
  uncomment_lines ".github/workflows/ci.yml", /RAILS_MASTER_KEY/
end

def add_migrations
  copy_file "db/migrate/20251121192825_devise_create_users.rb"
  copy_file "db/migrate/20251122141432_create_organizations.rb"
  copy_file "db/migrate/20251122141520_create_memberships.rb"
end

def add_procfiles
  copy_file "Procfile"
  append_to_file "Procfile.dev", "worker: bundle exec sidekiq -c 10"
end

def configure_database
  gsub_file "config/database.yml", /^production:.*?password:.*?\n/m, <<~YAML
    production:
      <<: *default
      url: <%= ENV["DATABASE_URL"] %>
  YAML
end

def add_application_code
  # Controllers and Pages
  copy_file "app/controllers/pages_controller.rb"
  copy_file "app/views/pages/home.html.erb"

  # Models
  copy_file "app/models/membership.rb"
  copy_file "app/models/organization.rb"
  copy_file "app/models/user.rb"
  copy_file "app/models/user/account.rb"

  # Application Partials
  copy_file "app/views/application/_card.html.erb"
  copy_file "app/views/application/_error_messages.html.erb"
  copy_file "app/views/application/_flashes.html.erb"
  copy_file "app/views/application/_nav.html.erb"

  # Devise Views
  copy_file "app/views/devise/confirmations/new.html.erb"
  copy_file "app/views/devise/passwords/edit.html.erb"
  copy_file "app/views/devise/passwords/new.html.erb"
  copy_file "app/views/devise/registrations/edit.html.erb"
  copy_file "app/views/devise/registrations/new.html.erb"
  copy_file "app/views/devise/sessions/new.html.erb"
  copy_file "app/views/devise/shared/_links.html.erb"

  # Application Layout
  gsub_file "app/views/layouts/application.html.erb", /<html>/, "<html lang=\"<%= I18n.locale %>\">"
  application_html_erb = <<-ERB
    <%= render "nav" %>
    <main class="container" aria-labelledby="main_label">
      <%= render "flashes" %>
      <%= yield %>
    </main>
  ERB
  gsub_file "app/views/layouts/application.html.erb", /^    <%= yield %>\n/, application_html_erb
end

def configure_environments
  environment "config.active_job.queue_adapter = :sidekiq"
  environment "config.active_record.strict_loading_by_default = true"
  environment "config.active_record.strict_loading_mode = :n_plus_one_only"
  environment "config.require_master_key = true"

  environment "config.sandbox_by_default = true", env: "production"
  environment "config.active_record.action_on_strict_loading_violation = :log", env: "production"
  gsub_file "config/environments/production.rb", /# config\.asset_host =.*$/, 'config.asset_host = ENV["ASSET_HOST"]'
  gsub_file "config/environments/production.rb", /config\.action_mailer\.default_url_options = \{ host: .*? \}/, 'config.action_mailer.default_url_options = { host: ENV.fetch("APPLICATION_HOST") }'

  environment "config.active_model.i18n_customize_full_message = true", env: "development"
  uncomment_lines "config/environments/development.rb", /config\.i18n\.raise_on_missing_translations/
  uncomment_lines "config/environments/development.rb", /config\.generators\.apply_rubocop_autocorrect_after_generate!/

  gsub_file "config/environments/test.rb", /config\.action_dispatch\.show_exceptions = :rescuable/, "config.action_dispatch.show_exceptions = :none"
  gsub_file "config/environments/test.rb", /config\.action_mailer\.default_url_options = \{ host: .*? \}/, "config.action_mailer.default_url_options = { host: \"localhost\", port: 3001 }"
  uncomment_lines "config/environments/test.rb", /config\.i18n\.raise_on_missing_translations/
  environment "config.active_job.queue_adapter = :inline", env: "test"
end

def add_high_voltage_initializer
  copy_file "config/initializers/high_voltage.rb"
end

def add_sidekiq_initializer
  copy_file "config/initializers/sidekiq.rb"
end

def configure_routes
  prepend_to_file "config/routes.rb", "require \"sidekiq/web\"\n\n"
  sidekiq_route = <<-RUBY
    if Rails.env.local?
      mount Sidekiq::Web => "/sidekiq"
    end

  RUBY

  insert_into_file "config/routes.rb", sidekiq_route, after: "Rails.application.routes.draw do\n  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html\n"
  route "devise_for :users"
  route 'root to: "pages#show", id: "home"'
  gsub_file "config/routes.rb", /  # Defines the root path route.*\n  # root "posts#index"\n/, ""
end

def add_rake_tasks
  copy_file "lib/development/seeder.rb"
  copy_file "lib/tasks/development.rake"
end

def add_test_suite
  copy_file "test/controllers/devise/registrations_controller_test.rb"
  copy_file "test/factories/memberships.rb"
  copy_file "test/factories/organizations.rb"
  copy_file "test/factories/users.rb"
  copy_file "test/models/membership_test.rb"
  copy_file "test/models/organization_test.rb"
  copy_file "test/models/user_test.rb"
  copy_file "test/system/authentication_stories_test.rb"

  application_system_test_case = <<-RUBY

    def sign_in_as(user)
      visit new_user_session_path

      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"

      assert_text I18n.translate("devise.sessions.signed_in")
    end
  RUBY
  insert_into_file "test/application_system_test_case.rb", application_system_test_case, before: "end\n"

  test_helper_config = <<-RUBY
      include Devise::Test::IntegrationHelpers
      include Capybara::Email::DSL
      include FactoryBot::Syntax::Methods

      Capybara.configure do |config|
        Rails.application.config.action_mailer.default_url_options => { host:, port: }

        config.server = :puma, { Silent: true }
        config.server_port = port
        config.app_host = "http://\#{host}:\#{port}"
      end

  RUBY
  insert_into_file "test/test_helper.rb", test_helper_config, after: "class TestCase\n"
  insert_into_file "test/test_helper.rb", "require \"capybara/email\"\n", after: "require \"rails/test_help\"\n"
end

def configure_sass
  gsub_file "package.json", /"build:css:compile": "sass \.\/app\/assets\/stylesheets\/application\.bootstrap\.scss:\.\/app\/assets\/builds\/application\.css --no-source-map --load-path=node_modules"/, '"build:css:compile": "sass ./app/assets/stylesheets/application.bootstrap.scss:./app/assets/builds/application.css --no-source-map --load-path=node_modules --silence-deprecation=import --silence-deprecation=global-builtin --silence-deprecation=color-functions"'
end

def run_migrations
  rails_command "db:create"
  rails_command "db:migrate"
end

def update_readme
  remove_file "README.md"
  copy_file "README.md"
end

def lint_codebase
  run "bin/rubocop -a"
end

def print_message
  say "*" * 50
  say "Installation complete! 🎉"
  say "*" * 50
end

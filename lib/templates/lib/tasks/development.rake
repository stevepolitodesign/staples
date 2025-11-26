if Rails.env.local?
  namespace :development do
    namespace :db do
      desc "Loads seed data for the local environment."
      task seed: :environment do
        Development::Seeder.load_seeds
      end

      namespace :seed do
        desc "Truncate tables of each database for development and loads seed data."
        task replant: ["environment", "db:truncate_all", "development:db:seed"]
      end
    end
  end
end

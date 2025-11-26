# frozen_string_literal: true

module Staples
  # Command-line interface for generating Rails applications with opinionated defaults.
  #
  # This class handles the creation of new Rails applications with predefined
  # configuration options including PostgreSQL database, Bootstrap CSS, and
  # skipping Solid Queue.
  class CLI
    # Default options passed to the Rails generator.
    #
    # @return [Array<String>] the list of Rails CLI options
    BASE_OPTIONS = [
      "-d=postgresql",
      "--css=bootstrap",
      "--skip-solid"
    ]

    # Initializes a new CLI instance.
    #
    # @param app_name [String] the name of the Rails application to create
    def initialize(app_name)
      @app_name = app_name
    end

    # Creates and runs a new CLI instance.
    #
    # @param app_name [String] the name of the Rails application to create
    # @return [Boolean] true if the Rails app was created successfully
    # @raise [Error] if Rails is not installed or app creation fails
    def self.run(app_name)
      new(app_name).run
    end

    # Executes the Rails application generation process.
    #
    # @return [Boolean] true if the Rails app was created successfully
    # @raise [Error] if Rails is not installed or app creation fails
    def run
      verify_rails_exists!
      generate_new_rails_app
    end

    private

    attr_reader :app_name

    def verify_rails_exists!
      unless system("which", "rails", out: File::NULL, err: File::NULL)
        raise Error, "Rails not found. Install with: gem install rails"
      end
    end

    def generate_new_rails_app
      template_path = File.expand_path("../templates/base.rb", __dir__)
      options = BASE_OPTIONS + ["-m=#{template_path}"]

      if system("rails", "new", app_name, *options)
        true
      else
        raise Error, "Failed to create Rails app"
      end
    end
  end
end

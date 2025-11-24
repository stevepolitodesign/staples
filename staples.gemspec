# frozen_string_literal: true

require_relative "lib/staples/version"

Gem::Specification.new do |spec|
  spec.name = "staples"
  spec.version = Staples::VERSION
  spec.authors = ["Steve Polito"]
  spec.email = ["stevepolito@hey.com"]

  spec.summary = "The basic ingredients for your next Rails project."
  spec.description = "The basic ingredients for your next Rails project."
  spec.homepage = "https://github.com/stevepolitodesign/staples"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/stevepolitodesign/staples"
  spec.metadata["changelog_uri"] = "https://github.com/stevepolitodesign/staples/blob/sp-mvp/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .standard.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

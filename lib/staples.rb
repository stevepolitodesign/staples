# frozen_string_literal: true

require_relative "staples/version"
require_relative "staples/cli"

# The Staples module provides a CLI tool for generating opinionated Rails applications.
#
# This gem wraps the Rails application generator with a predefined set of options
# to quickly scaffold new Rails projects with PostgreSQL, Bootstrap CSS, and other
# opinionated defaults.
module Staples
  # Base error class for all Staples-specific errors.
  class Error < StandardError; end
end

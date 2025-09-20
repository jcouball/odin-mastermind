# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  # This configures SimpleCov to measure branch coverage
  enable_coverage :branch
  primary_coverage :branch

  # This enforces 100% coverage for both lines and branches.
  # The test suite will fail if coverage drops below this threshold.
  minimum_coverage line: 100, branch: 100

  # Group related files in the coverage report
  add_group 'Library', 'lib'
  add_group 'Executables', 'exe'
  add_group 'Tests', 'spec'
end

require 'odin/mastermind'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

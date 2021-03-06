# frozen_string_literal: true

require_relative "helpers/stub_configuration"
require_relative "helpers/stub_metrics"
require_relative "helpers/stub_object_storage"
require_relative "helpers/stub_env"
require 'rubocop/rspec/support'

RSpec.configure do |config|
  config.mock_with :rspec
  config.raise_errors_for_deprecations!

  config.include StubConfiguration
  config.include StubMetrics
  config.include StubObjectStorage
  config.include StubENV

  config.include RuboCop::RSpec::ExpectOffense, type: :rubocop
end

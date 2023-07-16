# frozen_string_literal: true

require "simplecov"

if ENV["COVERAGE"]
  SimpleCov.start do
    add_filter "/spec/"
    enable_coverage :branch
  end
end

require "vcr"
require "webmock/rspec"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/cassettes"
  config.hook_into(:webmock)
end

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "connect"

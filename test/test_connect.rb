# frozen_string_literal: true

require "test_helper"

class TestConnect < Minitest::Test
  def test_version_number
    refute_nil ::Connect::VERSION
  end
end

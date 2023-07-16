# frozen_string_literal: true

RSpec.describe(Connect) do
  it "has a version number" do
    expect(Connect::VERSION).not_to(be_nil)
  end
end

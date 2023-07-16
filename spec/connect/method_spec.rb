# frozen_string_literal: true

require "google/protobuf/empty_pb"

RSpec.describe(Connect::Method) do
  subject(:method) do
    described_class.new(
      name: :TestUnary,
      request_type: Connect::Method::Unary.new(Google::Protobuf::Empty),
      response_type: Connect::Method::Unary.new(Google::Protobuf::Empty),
      ruby_method: :test_unary,
    )
  end

  describe "#inspect" do
    it "returns a string representation of the method" do
      expect(method.inspect).to(eq("#<Connect::Method name=:TestUnary request_type=Connect::Method::Unary<Google::Protobuf::Empty> response_type=Connect::Method::Unary<Google::Protobuf::Empty> ruby_method=:test_unary>")) # rubocop:disable Layout/LineLength
    end
  end
end

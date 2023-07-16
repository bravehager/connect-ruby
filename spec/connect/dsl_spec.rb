# frozen_string_literal: true

require "google/protobuf/empty_pb"

RSpec.describe(Connect::DSL) do
  subject(:klass) do
    Class.new do
      extend Connect::DSL
    end
  end

  describe ".service" do
    subject(:klass) do
      Class.new do
        extend Connect::DSL
        self.service = "test.TestService"
      end
    end

    it "returns the service" do
      expect(klass.service).to(eq("test.TestService"))
    end
  end

  describe ".service=" do
    it "sets the service" do
      klass.service = "test.TestService"
      expect(klass.service).to(eq("test.TestService"))
    end
  end

  describe ".rpc" do
    subject(:klass) do
      Class.new do
        extend Connect::DSL

        rpc :TestUnary, Google::Protobuf::Empty, Google::Protobuf::Empty
        rpc :TestStream, stream(Google::Protobuf::Empty), stream(Google::Protobuf::Empty)
      end
    end

    it "adds a unary method" do
      expect(klass.rpcs[:TestUnary]).to(eq(
        Connect::Method.new(
          name: :TestUnary,
          request_type: Connect::Method::Unary.new(Google::Protobuf::Empty),
          response_type: Connect::Method::Unary.new(Google::Protobuf::Empty),
          ruby_method: :test_unary,
        ),
      ))
    end

    it "adds a stream method" do
      expect(klass.rpcs[:TestStream]).to(eq(
        Connect::Method.new(
          name: :TestStream,
          request_type: Connect::Method::Stream.new(Google::Protobuf::Empty),
          response_type: Connect::Method::Stream.new(Google::Protobuf::Empty),
          ruby_method: :test_stream,
        ),
      ))
    end

    it "wraps message types" do
      klass.rpc(:TestUnary, Google::Protobuf::Empty, Google::Protobuf::Empty)

      expect(klass.rpcs[:TestUnary]).to(eq(
        Connect::Method.new(
          name: :TestUnary,
          request_type: Connect::Method::Unary.new(Google::Protobuf::Empty),
          response_type: Connect::Method::Unary.new(Google::Protobuf::Empty),
          ruby_method: :test_unary,
        ),
      ))
    end

    it "does not wrap message types if already wrapped" do
      klass.rpc(
        :TestUnary,
        Connect::Method::Unary.new(Google::Protobuf::Empty),
        Connect::Method::Unary.new(Google::Protobuf::Empty),
      )

      expect(klass.rpcs[:TestUnary]).to(eq(
        Connect::Method.new(
          name: :TestUnary,
          request_type: Connect::Method::Unary.new(Google::Protobuf::Empty),
          response_type: Connect::Method::Unary.new(Google::Protobuf::Empty),
          ruby_method: :test_unary,
        ),
      ))
    end

    it "converts name to symbol" do
      klass.rpc("TestUnary", Google::Protobuf::Empty, Google::Protobuf::Empty)

      expect(klass.rpcs[:TestUnary]).to(eq(
        Connect::Method.new(
          name: :TestUnary,
          request_type: Connect::Method::Unary.new(Google::Protobuf::Empty),
          response_type: Connect::Method::Unary.new(Google::Protobuf::Empty),
          ruby_method: :test_unary,
        ),
      ))
    end

    it "uses ruby_method if provided" do
      klass.rpc(:TestUnary, Google::Protobuf::Empty, Google::Protobuf::Empty, ruby_method: :do_test_unary)

      expect(klass.rpcs[:TestUnary]).to(eq(
        Connect::Method.new(
          name: :TestUnary,
          request_type: Connect::Method::Unary.new(Google::Protobuf::Empty),
          response_type: Connect::Method::Unary.new(Google::Protobuf::Empty),
          ruby_method: :do_test_unary,
        ),
      ))
    end
  end
end

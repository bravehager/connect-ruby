# frozen_string_literal: true

module Connect
  class Method
    class Type
      attr_reader :klass

      def initialize(klass)
        @klass = klass
      end

      def encode(input)
        klass.encode(input)
      end

      def decode(input)
        klass.decode(input)
      end

      def unary?
        false
      end

      def stream?
        false
      end

      def ==(other)
        other.is_a?(Type) && klass == other.klass
      end

      def inspect
        "#{self.class.name}<#{klass.inspect}>"
      end
    end

    class Unary < Type
      def unary?
        true
      end
    end

    class Stream < Type
      def stream?
        true
      end
    end

    attr_reader :name, :request_type, :response_type, :ruby_method

    def initialize(name:, request_type:, response_type:, ruby_method:)
      @name = name
      @request_type = request_type
      @response_type = response_type
      @ruby_method = ruby_method
    end

    def unary?
      request_type.unary? && response_type.unary?
    end

    def stream?
      request_type.stream? || response_type.stream?
    end

    def bidi_stream?
      request_type.stream? && response_type.stream?
    end

    def encode_request(input, max_bytes:)
      output = request_type.encode(input)
      raise MaxBytesExceededError, "Request exceeded maximum size of #{max_bytes} bytes" if output.bytesize > max_bytes

      output
    end

    def decode_response(input, max_bytes:)
      raise MaxBytesExceededError, "Response exceeded maximum size of #{max_bytes} bytes" if input.bytesize > max_bytes

      response_type.decode(input)
    end

    def ==(other)
      other.is_a?(Method) &&
        name == other.name &&
        request_type == other.request_type &&
        response_type == other.response_type &&
        ruby_method == other.ruby_method
    end

    def inspect
      "#<#{self.class.name} name=#{name.inspect} request_type=#{request_type.inspect} response_type=#{response_type.inspect} ruby_method=#{ruby_method.inspect}>" # rubocop:disable Layout/LineLength
    end
  end
end

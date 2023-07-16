# frozen_string_literal: true

module Connect
  class Client
    extend DSL

    class << self
      def on_rpc_method_added(method)
        define_method(method.ruby_method) do |input, header: {}, trailer: {}|
          call(method: method, input: input, header: header, trailer: trailer)
        end
      end
    end

    attr_reader :transport

    def initialize(transport:)
      @transport = transport
    end

    def call(method:, input:, header: {}, trailer: {})
      if method.unary?
        transport.unary(service: service, method: method, input: input, header: header, trailer: trailer)
      elsif method.stream?
        transport.stream(service: service, method: method, input: input, header: header, trailer: trailer)
      else
        raise UnknownMethodError, "Unknown method type: #{method.class}"
      end
    end

    def service
      self.class.service
    end
  end
end

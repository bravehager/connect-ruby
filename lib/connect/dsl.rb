# frozen_string_literal: true

module Connect
  module DSL
    def service
      @service
    end

    def service=(service)
      @service = service
    end

    def rpc(name, request, response, ruby_method: nil)
      method = Method.new(
        name: name.to_sym,
        request_type: wrap_message_type(request),
        response_type: wrap_message_type(response),
        ruby_method: ruby_method&.to_sym || underscore(name).to_sym,
      )
      rpcs[name] = method

      on_rpc_method_added(method)
    end

    def rpcs
      @rpcs ||= {}
    end

    def on_rpc_method_added(method)
    end

    private

    def wrap_message_type(klass)
      case klass
      when Method::Unary
        klass
      when Method::Stream
        klass
      else
        unary(klass)
      end
    end

    def unary(klass)
      Method::Unary.new(klass)
    end

    def stream(klass)
      Method::Stream.new(klass)
    end

    def underscore(string)
      s = string.to_s.dup
      s.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      s.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      s.tr!("-", "_")
      s.downcase!
      s
    end
  end
end

# frozen_string_literal: true

module Connect
  class Service
    extend DSL

    class << self
      def on_rpc_method_added(method)
      end
    end
  end
end

# frozen_string_literal: true

require "connect"
require_relative "eliza_pb"

module Buf
  module Connect
    module Demo
      module Eliza
        module V1
          module ElizaService
            class Service < ::Connect::Service
              self.service = "buf.connect.demo.eliza.v1.ElizaService"

              rpc :Say, SayRequest, SayResponse
              rpc :Converse, stream(ConverseRequest), stream(ConverseResponse)
              rpc :Introduce, IntroduceRequest, stream(IntroduceResponse)
            end

            class Client < ::Connect::Client
              self.service = "buf.connect.demo.eliza.v1.ElizaService"

              rpc :Say, SayRequest, SayResponse
              rpc :Converse, stream(ConverseRequest), stream(ConverseResponse)
              rpc :Introduce, IntroduceRequest, stream(IntroduceResponse)
            end
          end
        end
      end
    end
  end
end

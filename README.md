# connect-ruby

Idiomatic Connect RPCs for Ruby.

```ruby
require "connect"
require_relative "ping_pb"

module Ping
  module V1
    module PingService
      class Client < ::Connect::Service
        self.service = "ping.v1.PingService"

        rpc :Ping, PingRequest, PingResponse
        rpc :PingStream, PingRequest, stream(PingResponse)
      end
    end
  end
end

client = Ping::V1::PingService::Client.new(
  transport: Connect::Transport.new(base_url: "http://localhost:8080")
)

response = client.ping(
  PingRequest.new(message: "Hello, world!")
)

puts response.message # => "Hello, world!"

response = client.ping_stream(
  PingRequest.new(message: "Hello, world!")
)

response.each do |message|
  puts message # => "Hello, world!"
end
```

## Supported features

Note that this gem only supports HTTP/1.1. HTTP/2 is not supported.

## Client

- [x] Unary (Request-Response) RPCs
- [x] Client streaming and server streaming RPCs
- [ ] Bidirectional Streaming RPCs (not supported in HTTP/1.1)

## Server

- [ ] Unary (Request-Response) RPCs
- [ ] Client streaming and server streaming RPCs
- [ ] Bidirectional Streaming RPCs (not supported in HTTP/1.1)

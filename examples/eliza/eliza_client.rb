# frozen_string_literal: true

require_relative "eliza_connect"

client = Buf::Connect::Demo::Eliza::V1::ElizaService::Client.new(
  transport: Connect::Transport.new(
    base_url: "http://localhost:8080",
    send_compression: Connect::Compression::Gzip,
    accept_compression: [Connect::Compression::Gzip],
  ),
)

puts "Starting unary request..."

start_time = Time.now

response = client.say(Buf::Connect::Demo::Eliza::V1::SayRequest.new(sentence: "Hello"))

duration_ms = (Time.now - start_time) * 1000

puts "Received unary response: #{response.inspect} in #{duration_ms.round(2)}ms"

puts "Starting stream request..."

start_time = Time.now

stream = client.introduce(Buf::Connect::Demo::Eliza::V1::IntroduceRequest.new(name: "Jane Doe"))

puts "Received stream response: #{stream.inspect}"

stream.each do |message|
  puts "Received stream message: #{message.inspect}"
end

duration_ms = (Time.now - start_time) * 1000

puts "Received stream trailer: #{stream.trailer.inspect}"

puts "Finished stream request in #{duration_ms.round(2)}ms"

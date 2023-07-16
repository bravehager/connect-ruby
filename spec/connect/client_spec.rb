# frozen_string_literal: true

require "support/eliza_connect"

RSpec.describe(Connect::Client) do
  subject(:client) { Buf::Connect::Demo::Eliza::V1::ElizaService::Client.new(transport: transport) }

  let(:transport) do
    Connect::Transport.new(
      base_url: base_url,
      accept_compression: accept_compression,
      send_compression: send_compression,
      compress_min_bytes: compress_min_bytes,
      read_max_bytes: read_max_bytes,
      write_max_bytes: write_max_bytes,
    )
  end

  let(:base_url) { "http://localhost:8080" }
  let(:accept_compression) { [] }
  let(:send_compression) { nil }
  let(:compress_min_bytes) { 1024 }
  let(:read_max_bytes) { 0xffffffff }
  let(:write_max_bytes) { 0xffffffff }

  describe "#call" do
    context "with unknown method type" do
      let(:method) { Class.new(Connect::Method::Type).new(Google::Protobuf::Empty) }

      it "raises unknown method error on request" do
        expect do
          client.call(
            method: method,
            input: Google::Protobuf::Empty.new,
          )
        end.to(raise_error(Connect::UnknownMethodError))
      end
    end
  end

  describe "#unary" do
    let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Say" }
    let(:preserve_exact_body_bytes) { false }
    let(:response) { client.say(input, header: header, trailer: trailer) }
    let(:input) { Buf::Connect::Demo::Eliza::V1::SayRequest.new(sentence: "Hello, world!") }
    let(:header) { {} }
    let(:trailer) { {} }

    around do |example|
      VCR.use_cassette(cassette, preserve_exact_body_bytes: preserve_exact_body_bytes) { example.run }
    end

    it "sends request and receives response" do
      expect(response.message).to(be_a(Buf::Connect::Demo::Eliza::V1::SayResponse))
    end

    context "with accept gzip compression" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Say-AcceptGzip" }
      let(:accept_compression) { [Connect::Compression::Gzip] }

      it "sends request and receives response" do
        expect(response.message).to(be_a(Buf::Connect::Demo::Eliza::V1::SayResponse))
      end
    end

    context "with send gzip compression" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Say-SendGzip" }
      let(:preserve_exact_body_bytes) { true }
      let(:send_compression) { Connect::Compression::Gzip }
      let(:accept_compression) { [Connect::Compression::Gzip] }
      let(:compress_min_bytes) { 0 }

      it "sends request and receives response" do
        expect(response.message).to(be_a(Buf::Connect::Demo::Eliza::V1::SayResponse))
      end
    end

    context "with unknown compression" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Say-AcceptGzip" }
      let(:accept_compression) { [] }

      it "raises error" do
        expect do
          response
        end.to(raise_error(
          Connect::UnknownCompressionError,
          "Received unknown compression: gzip. Supported encodings are: []",
        ))
      end
    end

    context "when message exceeds write_max_bytes" do
      let(:write_max_bytes) { 0 }

      it "raises error" do
        expect do
          response
        end.to(raise_error(Connect::MaxBytesExceededError, /Request exceeded maximum size of 0 bytes/))
      end
    end

    context "when message exceeds read_max_bytes" do
      let(:read_max_bytes) { 0 }

      it "raises error" do
        expect do
          response.to_a
        end.to(raise_error(Connect::MaxBytesExceededError, /Response exceeded maximum size of 0 bytes/))
      end
    end

    context "with nefarious compression header" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Say-WithInvalidContentEncoding" }
      let(:send_compression) { Connect::Compression::Gzip }
      let(:compress_min_bytes) { 0 }
      let(:header) { { "content-encoding" => "identity" } }

      it "raises error" do
        expect do
          response
        end.to(raise_error(
          Connect::Error,
          "unmarshal into *elizav1.SayRequest: proto: cannot parse invalid wire-format data",
        ))
      end
    end
  end

  describe "#stream" do
    let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Introduce" }
    let(:preserve_exact_body_bytes) { false }
    let(:response) { client.introduce(input, header: header, trailer: trailer) }
    let(:input) { Buf::Connect::Demo::Eliza::V1::IntroduceRequest.new(name: "Jane Doe") }
    let(:header) { {} }
    let(:trailer) { {} }

    around do |example|
      VCR.use_cassette(cassette, preserve_exact_body_bytes: preserve_exact_body_bytes) { example.run }
    end

    it "sends stream request and receives streaming response" do
      expect(response).to(all(be_a(Buf::Connect::Demo::Eliza::V1::IntroduceResponse)))
    end

    context "with request header" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Introduce-WithRequestHeader" }
      let(:header) { { "x-header" => "foo" } }

      it "sends stream request and receives streaming response" do
        expect(response).to(all(be_a(Buf::Connect::Demo::Eliza::V1::IntroduceResponse)))
      end
    end

    context "with request trailer" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Introduce-WithRequestTrailer" }
      let(:trailer) { { "x-trailer" => "foo" } }

      it "sends stream request and receives streaming response" do
        expect(response).to(all(be_a(Buf::Connect::Demo::Eliza::V1::IntroduceResponse)))
      end
    end

    context "with response header" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Introduce-WithResponseHeader" }

      it "parses header" do
        expect(response.header).to(include("x-header" => "foo"))
      end
    end

    context "with response trailer" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Introduce-WithResponseTrailer" }

      before do
        response.to_a
      end

      it "parses trailer" do
        expect(response.trailer).to(include("x-trailer" => "foo"))
      end
    end

    context "with accept gzip compression" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Introduce-AcceptGzip" }
      let(:accept_compression) { [Connect::Compression::Gzip] }

      it "sends stream request and receives streaming response" do
        expect(response).to(all(be_a(Buf::Connect::Demo::Eliza::V1::IntroduceResponse)))
      end
    end

    context "with send gzip compression" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Introduce-SendGzip" }
      let(:preserve_exact_body_bytes) { true }
      let(:send_compression) { Connect::Compression::Gzip }
      let(:accept_compression) { [Connect::Compression::Gzip] }
      let(:compress_min_bytes) { 0 }

      it "sends stream request and receives streaming response" do
        expect(response).to(all(be_a(Buf::Connect::Demo::Eliza::V1::IntroduceResponse)))
      end
    end

    context "with unknown compression" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Introduce-AcceptGzip" }
      let(:accept_compression) { [] }

      it "raises error" do
        expect do
          response
        end.to(raise_error(
          Connect::UnknownCompressionError,
          "Received unknown compression: gzip. Supported encodings are: []",
        ))
      end
    end

    context "when message exceeds write_max_bytes" do
      let(:write_max_bytes) { 0 }

      it "raises error" do
        expect do
          response
        end.to(raise_error(Connect::MaxBytesExceededError, /Request exceeded maximum size of 0 bytes/))
      end
    end

    context "when message exceeds read_max_bytes" do
      let(:read_max_bytes) { 0 }

      it "raises error" do
        expect do
          response.to_a
        end.to(raise_error(Connect::MaxBytesExceededError, /Response exceeded maximum size of 0 bytes/))
      end
    end

    context "with bidi streaming method" do
      it "raises not implemented error" do
        expect do
          client.converse(
            Enumerator.new do |yielder|
              yielder << Buf::Connect::Demo::Eliza::V1::ConverseRequest.new(sentence: "Hello, world!")
            end.lazy,
          )
        end.to(raise_error(NotImplementedError, /Bidi streaming is not supported/))
      end
    end

    context "with enumerable input" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Introduce-EnumerableInput" }
      let(:input) do
        [
          Buf::Connect::Demo::Eliza::V1::IntroduceRequest.new(name: "Jane Doe"),
          Buf::Connect::Demo::Eliza::V1::IntroduceRequest.new(name: "John Doe"),
        ]
      end

      it "sends stream request and receives streaming response" do
        expect(response).to(all(be_a(Buf::Connect::Demo::Eliza::V1::IntroduceResponse)))
      end
    end

    context "with unexhausted stream response" do
      it "raises error reading trailer" do
        expect do
          response.trailer
        end.to(raise_error(Connect::StreamReadError, "Cannot read trailer before stream is exhausted"))
      end

      it "raises error reading error" do
        expect do
          response.error
        end.to(raise_error(Connect::StreamReadError, "Cannot read error before stream is exhausted"))
      end
    end

    context "with exhausted stream response" do
      before do
        response.to_a
      end

      it "reads trailer" do
        expect(response.trailer).to(be_nil)
      end

      it "reads error" do
        expect(response.error).to(be_nil)
      end
    end

    context "with invalid end stream message" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Introduce-WithInvalidEndStreamMessage" }

      it "raises error" do
        expect do
          response.to_a
        end.to(raise_error(Connect::InvalidStreamResponseError))
      end
    end

    context "when stream response does not end with end stream message" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Introduce-WithoutEndStreamMessage" }

      it "raises error" do
        expect do
          response.to_a
        end.to(raise_error(Connect::InvalidStreamResponseError, "Stream did not end with end stream message"))
      end
    end

    context "with nefarious compression header" do
      let(:cassette) { "buf.connect.demo.eliza.v1.ElizaService/Introduce-WithInvalidContentEncoding" }
      let(:preserve_exact_body_bytes) { true }
      let(:send_compression) { Connect::Compression::Gzip }
      let(:compress_min_bytes) { 0 }
      let(:header) { { "connect-content-encoding" => "identity" } }

      it "raises error" do
        expect do
          response.to_a
        end.to(raise_error(
          Connect::Error,
          "gRPC protocol error: sent compressed message without Grpc-Encoding header",
        ))
      end
    end
  end
end

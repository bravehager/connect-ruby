# frozen_string_literal: true

module Connect
  class Transport
    attr_reader :base_url,
      :accept_compression,
      :send_compression,
      :compress_min_bytes,
      :read_max_bytes,
      :write_max_bytes

    def initialize(
      base_url:,
      accept_compression: [Compression::Gzip],
      send_compression: Compression::Gzip,
      compress_min_bytes: 1024,
      read_max_bytes: 0xffffffff,
      write_max_bytes: 0xffffffff
    )
      @base_url = base_url
      @accept_compression = accept_compression
      @send_compression = send_compression
      @compress_min_bytes = compress_min_bytes
      @read_max_bytes = read_max_bytes
      @write_max_bytes = write_max_bytes
    end

    def unary(service:, method:, input:, header:, trailer:)
      uri = build_uri(service: service, method: method)

      response = do_response(
        uri: uri,
        request: build_unary_request(uri: uri, method: method, input: input, header: header, trailer: trailer),
      )

      case response.code
      when "200"
        parse_unary_response(response: response, method: method)
      else
        raise parse_unary_error(response: response)
      end
    end

    def stream(service:, method:, input:, header:, trailer:)
      raise NotImplementedError, "Bidi streaming is not supported with HTTP/1.1" if method.bidi_stream?

      uri = build_uri(service: service, method: method)

      response = do_response(
        uri: uri,
        request: build_stream_request(uri: uri, method: method, input: input, header: header, trailer: trailer),
      )

      case response.code
      when "200"
        parse_stream_response(response: response, method: method)
      else
        raise Connect::Error.new(
          code: Code.for_http_code(response.code),
          message: "Unexpected HTTP status code: #{response.code}",
        )
      end
    end

    private

    def build_uri(service:, method:)
      URI("#{base_url}/#{service}/#{method.name}")
    end

    def do_response(uri:, request:)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end
    end

    def build_unary_request(uri:, method:, input:, header:, trailer:)
      request = Net::HTTP::Post.new(uri)

      request[CONNECT_HEADER_PROTOCOL_VERSION] = CONNECT_PROTOCOL_VERSION
      request[CONNECT_HEADER_CONTENT_TYPE] = "application/proto"

      request[CONNECT_UNARY_HEADER_ACCEPT_COMPRESSION] = if accept_compression.any?
        accept_compression.map(&:name).join(",")
      else
        CONNECT_COMPRESSION_IDENTITY
      end

      if send_compression
        request_compression = RequestCompression.new(
          compression: send_compression,
          compress_min_bytes: compress_min_bytes,
        )
      end

      message = method.encode_request(input, max_bytes: write_max_bytes)

      if request_compression&.compress?(message)
        request[CONNECT_UNARY_HEADER_COMPRESSION] = request_compression.compression.name
        request.body = request_compression.compression.compress(message)
      else
        request.body = message
      end

      inject_header_and_trailer(request: request, header: header, trailer: trailer)
    end

    def parse_unary_response(response:, method:)
      compression = parse_compression_from_header(response[CONNECT_UNARY_HEADER_COMPRESSION])

      message = if compression
        method.decode_response(compression.decompress(response.body), max_bytes: read_max_bytes)
      else
        method.decode_response(response.body, max_bytes: read_max_bytes)
      end

      header, trailer = parse_header_and_trailer(response: response)

      UnaryResponse.new(header: header, message: message, trailer: trailer)
    end

    def parse_unary_error(response:)
      message = JSON.parse(response.body)

      Error.new(
        code: message.fetch("code", Code.from_http_code(response.code)),
        message: message["message"],
        details: message["details"],
      )
    rescue JSON::ParserError
      Error.new(code: Code.from_http_code(response.code))
    end

    def build_stream_request(uri:, method:, input:, header:, trailer:)
      request = Net::HTTP::Post.new(uri)

      request[CONNECT_HEADER_PROTOCOL_VERSION] = CONNECT_PROTOCOL_VERSION
      request[CONNECT_HEADER_CONTENT_TYPE] = "application/connect+proto"

      request[CONNECT_UNARY_HEADER_ACCEPT_COMPRESSION] = CONNECT_COMPRESSION_IDENTITY

      request[CONNECT_STREAM_HEADER_ACCEPT_COMPRESSION] = if accept_compression.any?
        accept_compression.map(&:name).join(",")
      else
        CONNECT_COMPRESSION_IDENTITY
      end

      if send_compression
        request_compression = RequestCompression.new(
          compression: send_compression,
          compress_min_bytes: compress_min_bytes,
        )
        request[CONNECT_STREAM_HEADER_COMPRESSION] = request_compression.compression.name
      end

      buffer = StringIO.new

      enumerator = build_stream_request_enumerator(
        method: method,
        input: input.is_a?(Enumerable) ? input : [input],
        request_compression: request_compression,
      )

      enumerator.each do |enveloped|
        buffer << enveloped
      end

      buffer.rewind

      request["transfer-encoding"] = "chunked"
      request.body_stream = buffer

      inject_header_and_trailer(request: request, header: header, trailer: trailer)
    end

    def parse_stream_response(response:, method:)
      compression = parse_compression_from_header(response[CONNECT_STREAM_HEADER_COMPRESSION])

      enumerator = build_stream_response_enumerator(
        method: method,
        buffer: StringIO.new(response.body),
        compression: compression,
      )

      StreamResponse.new(header: response.each_header.to_h, enumerator: enumerator)
    end

    def build_stream_request_enumerator(method:, input:, request_compression:)
      Enumerator.new do |yielder|
        input.each do |message|
          yielder << Envelope.pack(
            method.encode_request(message, max_bytes: write_max_bytes),
            compression: request_compression&.compression,
            compress_min_bytes: request_compression&.compress_min_bytes,
          )
        end
      end
    end

    def build_stream_response_enumerator(method:, buffer:, compression:)
      Enumerator.new do |yielder|
        until buffer.eof?
          flags, data = Envelope.unpack(buffer, compression: compression)

          yielder << if flags & 2 == 0
            [flags, method.decode_response(data, max_bytes: read_max_bytes)]
          else
            [flags, parse_end_stream_message(data)]
          end
        end
      end
    end

    def parse_end_stream_message(data)
      JSON.parse(data)
    rescue JSON::ParserError
      raise InvalidStreamResponseError, "Invalid end stream message: #{data.inspect}"
    end

    def inject_header_and_trailer(request:, header:, trailer:)
      header.each do |key, value|
        request[key] = value
      end

      trailer.each do |key, value|
        request["#{CONNECT_UNARY_TRAILER_PREFIX}#{key}"] = value
      end

      request
    end

    def parse_header_and_trailer(response:, header: {}, trailer: {})
      response.each_header do |key, value|
        if key.start_with?(CONNECT_UNARY_TRAILER_PREFIX)
          trailer[key[CONNECT_UNARY_TRAILER_PREFIX.length..-1]] = value
        else
          header[key] = value
        end
      end

      [header, trailer]
    end

    def parse_compression_from_header(header)
      if header && header != CONNECT_COMPRESSION_IDENTITY
        compression = accept_compression.find { |c| c.name == header }

        unless compression
          accepted = accept_compression.map(&:name)

          raise UnknownCompressionError,
            "Received unknown compression: #{header}. Supported encodings are: #{accepted.inspect}"
        end

        compression
      end
    end
  end
end

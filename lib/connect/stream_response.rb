# frozen_string_literal: true

module Connect
  class StreamResponse
    include Enumerable

    END_OF_STREAM_FLAG = 0b00000010

    attr_reader :header

    def initialize(header:, enumerator:)
      @header = header
      @enumerator = enumerator
      @trailer = nil
      @error = nil
      @stream_exhausted = false
    end

    def each(&block)
      enumerator.each do |flags, message|
        if flags & END_OF_STREAM_FLAG == 0
          yield message
        else
          read_end_stream_message(message)
        end
      end

      raise InvalidStreamResponseError, "Stream did not end with end stream message" unless stream_exhausted?
    end

    def trailer
      raise StreamReadError, "Cannot read trailer before stream is exhausted" unless stream_exhausted?

      @trailer
    end

    def error
      raise StreamReadError, "Cannot read error before stream is exhausted" unless stream_exhausted?

      @error
    end

    def stream_exhausted?
      @stream_exhausted
    end

    private

    attr_reader :enumerator

    attr_writer :trailer, :error

    def read_end_stream_message(message)
      @stream_exhausted = true

      @trailer = message["metadata"]
      @error = message["error"]

      raise Error.new(
        code: Code.from_name(error["code"]),
        message: error["message"],
        details: error["details"],
        metadata: error["metadata"],
      ) if error
    end
  end
end

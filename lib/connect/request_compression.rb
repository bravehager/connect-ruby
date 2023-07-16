# frozen_string_literal: true

module Connect
  class RequestCompression
    attr_reader :compression, :compress_min_bytes

    def initialize(compression:, compress_min_bytes:)
      @compression = compression
      @compress_min_bytes = compress_min_bytes
    end

    def compress?(source)
      source.bytesize >= compress_min_bytes
    end
  end
end

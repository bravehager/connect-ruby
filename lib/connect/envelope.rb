# frozen_string_literal: true

module Connect
  class Envelope
    COMPRESSED_FLAG = 0b00000001

    class << self
      def pack(source, compression: nil, compress_min_bytes: nil)
        if compress_min_bytes.nil? || source.bytesize < compress_min_bytes || compression.nil?
          [0, source.bytesize, source].pack("CNa*")
        else
          compressed = compression.compress(source)
          [COMPRESSED_FLAG, compressed.bytesize, compressed].pack("CNa*")
        end
      end

      def unpack(source, compression: nil)
        flags, size = source.read(5).unpack("CN")

        if flags & COMPRESSED_FLAG == 0
          [flags, source.read(size)]
        else
          [flags, compression.decompress(source.read(size))]
        end
      end
    end
  end
end

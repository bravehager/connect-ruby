# frozen_string_literal: true

module Connect
  module Compression
    class Gzip
      class << self
        def name
          "gzip"
        end

        def compress(source)
          Zlib.gzip(source)
        end

        def decompress(source)
          Zlib.gunzip(source)
        end
      end
    end
  end
end

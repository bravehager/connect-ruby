# frozen_string_literal: true

module Connect
  class UnaryResponse
    attr_reader :header, :message, :trailer

    def initialize(header:, message:, trailer:)
      @header = header
      @message = message
      @trailer = trailer
    end
  end
end

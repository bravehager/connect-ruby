# frozen_string_literal: true

module Connect
  class Error < StandardError
    attr_reader :code, :message, :details, :metadata

    def initialize(code:, message: nil, details: nil, metadata: nil)
      super(message)

      @code = code
      @message = message
      @details = details
      @metadata = metadata
    end
  end
end

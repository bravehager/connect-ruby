# frozen_string_literal: true

module Connect
  class Code
    class << self
      def from_http_code(code)
        case code.to_i
        when 200 then Ok
        when 400 then InvalidArgument
        when 401 then Unauthenticated
        when 403 then PermissionDenied
        when 404 then NotFound
        when 408 then DeadlineExceeded
        when 409 then Aborted
        when 412 then FailedPrecondition
        when 413 then ResourceExhausted
        when 415 then Internal
        when 429 then Unavailable
        when 431 then ResourceExhausted
        when 502, 503, 504 then Unavailable
        else
          Unknown
        end
      end

      def from_name(name)
        CODES_BY_NAME.fetch(name, Unknown)
      end
    end

    attr_reader :name, :value

    def initialize(name, value)
      @name = name
      @value = value
    end

    def ==(other)
      other.is_a?(Code) && name == other.name && value == other.value
    end

    def inspect
      "#<#{self.class.name} name=#{name.inspect} value=#{value.inspect}>"
    end
  end
end

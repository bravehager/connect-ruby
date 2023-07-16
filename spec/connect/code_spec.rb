# frozen_string_literal: true

RSpec.describe(Connect::Code) do
  describe ".from_http_code" do
    it "returns the code for the given http code" do
      {
        200 => Connect::Ok,
        400 => Connect::InvalidArgument,
        401 => Connect::Unauthenticated,
        403 => Connect::PermissionDenied,
        404 => Connect::NotFound,
        408 => Connect::DeadlineExceeded,
        409 => Connect::Aborted,
        412 => Connect::FailedPrecondition,
        413 => Connect::ResourceExhausted,
        415 => Connect::Internal,
        429 => Connect::Unavailable,
        431 => Connect::ResourceExhausted,
        502 => Connect::Unavailable,
        503 => Connect::Unavailable,
        504 => Connect::Unavailable,
        999 => Connect::Unknown,
      }.each do |http_code, code|
        expect(described_class.from_http_code(http_code)).to(eq(code))
      end
    end
  end

  describe ".from_name" do
    it "returns the code for the given name" do
      expect(described_class.from_name("ok")).to(eq(Connect::Ok))
    end

    it "returns unknown for an unknown name" do
      expect(described_class.from_name("foo")).to(eq(Connect::Unknown))
    end
  end

  describe "#==" do
    it "is equal when the code and value are the same" do
      expect(described_class.new("ok", 0)).to(eq(Connect::Ok))
    end

    it "is not equal when the code is different" do
      expect(described_class.new("ok", 1)).not_to(eq(Connect::Ok))
    end

    it "is not equal when the value is different" do
      expect(described_class.new("canceled", 0)).not_to(eq(Connect::Ok))
    end
  end

  describe "#inspect" do
    it "returns a string representation of the code" do
      expect(described_class.new("ok", 0).inspect).to(eq("#<Connect::Code name=\"ok\" value=0>"))
    end
  end
end

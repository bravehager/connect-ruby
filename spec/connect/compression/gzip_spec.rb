# frozen_string_literal: true

RSpec.describe(Connect::Compression::Gzip) do
  subject(:compression) { described_class }

  describe ".name" do
    it "returns the expected name" do
      expect(compression.name).to(eq("gzip"))
    end
  end

  describe ".compress" do
    let(:source) { "Hello, world!" }

    it "compresses the source" do
      expect(compression.compress(source)).to(eq(Zlib.gzip(source)))
    end
  end

  describe ".decompress" do
    let(:source) { "Hello, world!" }

    it "decompresses the source" do
      expect(compression.decompress(Zlib.gzip(source))).to(eq(source))
    end
  end
end

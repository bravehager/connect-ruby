# frozen_string_literal: true

RSpec.describe(Connect::Envelope) do
  subject(:envelope) { described_class }

  it "packs and unpacks with compression" do
    enveloped = envelope.pack("Hello, world!", compression: Connect::Compression::Gzip, compress_min_bytes: 1)
    flags, data = envelope.unpack(StringIO.new(enveloped), compression: Connect::Compression::Gzip)

    expect([flags, data]).to(eq([1, "Hello, world!"]))
  end

  it "packs and unpacks without compression" do
    enveloped = envelope.pack("Hello, world!")
    flags, data = envelope.unpack(StringIO.new(enveloped))

    expect([flags, data]).to(eq([0, "Hello, world!"]))
  end

  it "packs and unpacks without compression when source is smaller than compress_min_bytes" do
    enveloped = envelope.pack("Hello, world!", compression: Connect::Compression::Gzip, compress_min_bytes: 1_00)
    flags, data = envelope.unpack(StringIO.new(enveloped), compression: Connect::Compression::Gzip)

    expect([flags, data]).to(eq([0, "Hello, world!"]))
  end
end

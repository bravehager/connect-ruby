# frozen_string_literal: true

require "uri"
require "json"
require "stringio"
require "net/http"
require "zlib"
require "google/protobuf"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/connect-ruby.rb")
loader.inflector.inflect(
  "dsl" => "DSL",
)
loader.setup

module Connect
  UnknownMethodError = Class.new(StandardError)
  MaxBytesExceededError = Class.new(StandardError)
  InvalidStreamResponseError = Class.new(StandardError)
  StreamReadError = Class.new(StandardError)
  UnknownCompressionError = Class.new(StandardError)

  Ok = Code.new("ok", 0)
  Canceled = Code.new("canceled", 1)
  Unknown = Code.new("unknown", 2)
  InvalidArgument = Code.new("invalid_argument", 3)
  DeadlineExceeded = Code.new("deadline_exceeded", 4)
  NotFound = Code.new("not_found", 5)
  AlreadyExists = Code.new("already_exists", 6)
  PermissionDenied = Code.new("permission_denied", 7)
  ResourceExhausted = Code.new("resource_exhausted", 8)
  FailedPrecondition = Code.new("failed_precondition", 9)
  Aborted = Code.new("aborted", 10)
  OutOfRange = Code.new("out_of_range", 11)
  Unimplemented = Code.new("unimplemented", 12)
  Internal = Code.new("internal", 13)
  Unavailable = Code.new("unavailable", 14)
  DataLoss = Code.new("data_loss", 15)
  Unauthenticated = Code.new("unauthenticated", 16)

  CODES = [
    Ok,
    Canceled,
    Unknown,
    InvalidArgument,
    DeadlineExceeded,
    NotFound,
    AlreadyExists,
    PermissionDenied,
    ResourceExhausted,
    FailedPrecondition,
    Aborted,
    OutOfRange,
    Unimplemented,
    Internal,
    Unavailable,
    DataLoss,
    Unauthenticated,
  ]

  CODES_BY_NAME = {
    "ok" => Ok,
    "canceled" => Canceled,
    "unknown" => Unknown,
    "invalid_argument" => InvalidArgument,
    "deadline_exceeded" => DeadlineExceeded,
    "not_found" => NotFound,
    "already_exists" => AlreadyExists,
    "permission_denied" => PermissionDenied,
    "resource_exhausted" => ResourceExhausted,
    "failed_precondition" => FailedPrecondition,
    "aborted" => Aborted,
    "out_of_range" => OutOfRange,
    "unimplemented" => Unimplemented,
    "internal" => Internal,
    "unavailable" => Unavailable,
    "data_loss" => DataLoss,
    "unauthenticated" => Unauthenticated,
  }.freeze

  CONNECT_HEADER_CONTENT_TYPE = "content-type"
  CONNECT_UNARY_HEADER_COMPRESSION = "content-encoding"
  CONNECT_UNARY_HEADER_ACCEPT_COMPRESSION = "accept-encoding"
  CONNECT_STREAM_HEADER_COMPRESSION = "connect-content-encoding"
  CONNECT_STREAM_HEADER_ACCEPT_COMPRESSION = "connect-accept-encoding"
  CONNECT_UNARY_TRAILER_PREFIX = "trailer-"
  CONNECT_UNARY_HEADER_TIMEOUT = "connect-timeout-ms"
  CONNECT_HEADER_PROTOCOL_VERSION = "connect-protocol-version"
  CONNECT_PROTOCOL_VERSION = "1"
  CONNECT_COMPRESSION_IDENTITY = "identity"
end

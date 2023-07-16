# frozen_string_literal: true

# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: eliza.proto

require "google/protobuf"

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("eliza.proto", syntax: :proto3) do
    add_message "buf.connect.demo.eliza.v1.SayRequest" do
      optional :sentence, :string, 1
    end
    add_message "buf.connect.demo.eliza.v1.SayResponse" do
      optional :sentence, :string, 1
    end
    add_message "buf.connect.demo.eliza.v1.ConverseRequest" do
      optional :sentence, :string, 1
    end
    add_message "buf.connect.demo.eliza.v1.ConverseResponse" do
      optional :sentence, :string, 1
    end
    add_message "buf.connect.demo.eliza.v1.IntroduceRequest" do
      optional :name, :string, 1
    end
    add_message "buf.connect.demo.eliza.v1.IntroduceResponse" do
      optional :sentence, :string, 1
    end
  end
end

module Buf
  module Connect
    module Demo
      module Eliza
        module V1
          SayRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("buf.connect.demo.eliza.v1.SayRequest").msgclass
          SayResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("buf.connect.demo.eliza.v1.SayResponse").msgclass
          ConverseRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("buf.connect.demo.eliza.v1.ConverseRequest").msgclass
          ConverseResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("buf.connect.demo.eliza.v1.ConverseResponse").msgclass
          IntroduceRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("buf.connect.demo.eliza.v1.IntroduceRequest").msgclass
          IntroduceResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("buf.connect.demo.eliza.v1.IntroduceResponse").msgclass
        end
      end
    end
  end
end

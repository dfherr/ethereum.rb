require 'spec_helper'

describe Ethereum::Encoder do

  let (:encoder) { Ethereum::Encoder.new }
  let (:decoder) { Ethereum::Decoder.new }

  it "parse type" do
    expect(Ethereum::Abi::parse_type("bool")).to eq ["bool", nil]
    expect(Ethereum::Abi::parse_type("uint32")).to eq ["uint", "32"]
    expect(Ethereum::Abi::parse_type("bytes32")).to eq ["bytes", "32"]
    expect(Ethereum::Abi::parse_type("fixed128x128")).to eq ["fixed", "128x128"]
  end

  RSpec::Matchers.define :encode_and_decode do |actual|
    match do |type|
      (encoder.encode(type, actual) == @expected) && (decoder.decode(type, @expected) == actual)
    end
    chain(:to) { |expected| @expected = expected }
  end

  context "uint" do
    specify { expect("uint").to encode_and_decode(20).to("0000000000000000000000000000000000000000000000000000000000000014") }
    specify { expect("uint32").to encode_and_decode(5).to("0000000000000000000000000000000000000000000000000000000000000005") }
    specify { expect("uint1").to encode_and_decode(5).to("0000000000000000000000000000000000000000000000000000000000000005") }
    specify { expect("uint256").to encode_and_decode(5).to("0000000000000000000000000000000000000000000000000000000000000005") }
  end

  context "int" do
    specify { expect("uint").to encode_and_decode(20).to("0000000000000000000000000000000000000000000000000000000000000014") }
    specify { expect("uint32").to encode_and_decode(5).to("0000000000000000000000000000000000000000000000000000000000000005") }
    specify { expect("uint1").to encode_and_decode(5).to("0000000000000000000000000000000000000000000000000000000000000005") }
    specify { expect("uint256").to encode_and_decode(5).to("0000000000000000000000000000000000000000000000000000000000000005") }
    specify { expect("int").to encode_and_decode(-20).to("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffec") }
    specify { expect("int32").to encode_and_decode(-1).to("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff") }
  end

  context "bool" do
    specify { expect("bool").to encode_and_decode(true).to("0000000000000000000000000000000000000000000000000000000000000001") }
    specify { expect("bool").to encode_and_decode(false).to("0000000000000000000000000000000000000000000000000000000000000000") }
  end

  context "address" do
    specify { expect("address").to encode_and_decode("0000000000000000000000000000000000000000").to("0000000000000000000000000000000000000000") }
    it { expect { decoder.decode("address", "000000000000000000000000000000000000000") }.to raise_error ArgumentError }
    it { expect { encoder.encode("address", "000000000000000000000000000000000000000") }.to raise_error ArgumentError }
    it { expect(encoder.encode("address", "0x0000000000000000000000000000000000000000")).to eq "0000000000000000000000000000000000000000" }
    it { expect(decoder.decode("address", "0x0000000000000000000000000000000000000000")).to eq "0000000000000000000000000000000000000000" }
  end

  context "bytes" do
    let (:location) { '0000000000000000000000000000000000000000000000000000000000000020' }
    let (:size) { '0000000000000000000000000000000000000000000000000000000000000004' }
    let (:content) { '6461766500000000000000000000000000000000000000000000000000000000' }
    let (:expected) { location + size + content }
    specify { expect("bytes").to encode_and_decode("dave").to(expected) }
  end

end
require "./spec_helper"

describe Heap do
  it "keeps track of initialization" do
    maddr = USize.new 0
    limit = USize.new 0
    Heap.initialized?.should eq false
    Heap.init maddr, limit
    Heap.initialized?.should eq true
  end

  it "allows reinitialization" do
    maddr = USize.new 1
    limit = USize.new 2
    Heap.init maddr, limit
    Heap.memory_address.should eq maddr
    Heap.memory_limit.should eq maddr + limit
  end

  it "calculates the right limit" do
    maddr = USize.new 0
    Heap.init maddr
    bits32 { Heap.memory_limit.should eq 0xFFFFFFFF_u32 }
    bits64 { Heap.memory_limit.should eq 0xFFFFFFFFFFFFFFFF_u64 }
  end
end

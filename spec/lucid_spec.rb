require 'spec_helper'
require 'pry'

vpc_name="sam-code-test"

describe vpc(vpc_name) do
  it { should exist }
  its(:cidr_block) { should eq '10.1.0.0/16' }
end


(0..2).each do |index|
  describe subnet("sam-code-test-private-#{index}") do
    it { should exist }
    it { should be_available }
    it { should belong_to_vpc(vpc_name) }
    end

  describe subnet("sam-code-test-private-#{index}") do
    it { should exist }
    it { should be_available }
    it { should belong_to_vpc(vpc_name) }
  end
end

describe nat_gateway('sam-code-test') do
  it { should exist }
  it { should be_available }
  it { should belong_to_vpc(vpc_name) }
end

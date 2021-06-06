require 'spec_helper'

vpc_name="sam-code-test"

describe rds('sam-code-test') do
  it { should exist }
end

describe alb_target_group('sam-code-test') do
  it { should exist }
  its(:health_check_path) { should eq '/' }
  its(:health_check_port) { should eq 'traffic-port' }
  its(:health_check_protocol) { should eq 'HTTP' }
  it { should belong_to_alb("sam-code-test") }
  it { should belong_to_vpc(vpc_name) }
end

describe alb('sam-code-test') do
  it { should exist }
  it { should be_active }
end

describe autoscaling_group('sam-code-test') do
  it { should exist }
  its(:launch_configuration_name) { should eq 'sam-code-test'}
  its(:min_size) { should eq 2 }
  its(:max_size) { should eq 2 }
  its(:desired_capacity) { should eq 2 }
end

describe launch_configuration('sam-code-test') do
  it { should exist }
  its(:instance_type) { should eq "t2.nano"}
end

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

require 'spec_helper'

vpc_name="sam-code-test"


describe security_group('sam-code-test-instance') do
  it { should exist }
  its(:outbound) { should be_opened }
  its(:inbound) { should be_opened(80).protocol('tcp').for('10.1.0.0/16') }
end

describe security_group('sam-code-test-alb') do
  it { should exist }
  its(:outbound) { should be_opened }
  # its(:inbound) { should be_opened(80).protocol('tcp').for('0.0.0.0/0') }
  its(:inbound) { should be_opened(80).protocol('tcp').for('0.0.0.0/0') }
end

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

# not ideal but since being able to swap LCs is more important
launch_config_name = "sam-code-test"
Dir.chdir("terraform") do
   launch_config_name = `terraform output launch_config_name`.strip.chomp('"').reverse.chomp('"').reverse
end

describe autoscaling_group('sam-code-test') do
  it { should exist }
  its(:launch_configuration_name) { should eq launch_config_name}
  its(:min_size) { should eq 2 }
  its(:max_size) { should eq 2 }
  its(:desired_capacity) { should eq 2 }
end

describe launch_configuration(launch_config_name) do
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


# not ideal but couldn't figure out how to get the subnet name tag in nat block
public_subnet_id = "subnet-1234567890"
Dir.chdir("terraform") do
   public_subnet_id = `terraform output public_subnet_id`.strip.chomp('"').reverse.chomp('"').reverse
end

describe nat_gateway('sam-code-test') do
  it { should exist }
  it { should be_available }
  it { should belong_to_vpc(vpc_name) }
  its(:subnet_id) { should eq public_subnet_id }
end

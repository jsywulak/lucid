data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "sam-code-test" {
  name          = "sam-code-test"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.nano"
}


resource "aws_autoscaling_group" "sam-code-test" {
  name                      = "sam-code-test"
  max_size                  = 0
  min_size                  = 0
  health_check_grace_period = 300
  #  health_check_type         = "ELB"
  desired_capacity     = 0
  force_delete         = true
  launch_configuration = aws_launch_configuration.sam-code-test.name
  vpc_zone_identifier  = [aws_subnet.private[0].id, aws_subnet.private[1].id, aws_subnet.private[2].id]

  tag {
    key                 = "Mame"
    value               = "sam-code-test"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}
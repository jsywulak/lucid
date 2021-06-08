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
  name_prefix     = "sam-code-test"
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = "t2.nano"
  user_data       = data.template_cloudinit_config.config.rendered
  security_groups = [aws_security_group.sam-code-test-instance.id]
  # key_name        = "jonny-lucid-test" # for troubleshooting
}

resource "aws_security_group" "sam-code-test-instance" {
  name   = "sam-code-test-instance"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "sam-code-test" {
  name                      = "sam-code-test"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.sam-code-test.name
  vpc_zone_identifier       = [aws_subnet.private[0].id, aws_subnet.private[1].id, aws_subnet.private[2].id]

  tag {
    key                 = "Name"
    value               = "sam-code-test-asg-instance"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
    echo "<h1>Good morning, Lucid</h1>" | sudo tee /var/www/html/index.html
    echo 'db_endpoint="${aws_db_instance.sam-code-test.endpoint}"<br/>' >> /var/www/html/index.html
    echo 'db_user="${aws_db_instance.sam-code-test.username}"<br/>' >> /var/www/html/index.html
    echo 'db_pass="${aws_ssm_parameter.sam-code-test.value}"<br/>' >> /var/www/html/index.html

    EOF
  }
}

# for troubleshooting
# resource "aws_instance" "bastion" {
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = "t3.micro"
#   key_name               = "jonny-lucid-test"
#   vpc_security_group_ids = [aws_security_group.sam-code-test-instance.id]
#   subnet_id              = aws_subnet.public[0].id
#   associate_public_ip_address = true
# 
#   tags = {
#     Name = "bastion"
#   }
# }

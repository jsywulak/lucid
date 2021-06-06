resource "aws_security_group" "sam-code-test" {
  name        = "sam-code-test"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_alb" "sam-code-test" {
  name               = "sam-code-test"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sam-code-test.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = false
}

resource "aws_alb_target_group" "sam-code-test" {
  name     = "sam-code-test"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_autoscaling_attachment" "sam-code-test" {
  autoscaling_group_name = aws_autoscaling_group.sam-code-test.id
  alb_target_group_arn   = aws_alb_target_group.sam-code-test.arn
}

resource "aws_lb_listener" "sam-code-test" {
  load_balancer_arn = aws_alb.sam-code-test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.sam-code-test.arn
  }
}
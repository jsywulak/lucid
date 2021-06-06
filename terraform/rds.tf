resource "aws_db_instance" "sam-code-test" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  identifier           = "sam-code-test"
  name                 = "samcodetest"
  username             = "admin"
  password             = aws_ssm_parameter.sam-code-test.value
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.sam-code-test.name
}

resource "aws_db_subnet_group" "sam-code-test" {
  name       = "main"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id, aws_subnet.private[2].id]

}

data "aws_ssm_parameter" "sam-code-test" {
  name       = "db_password"
  depends_on = [aws_ssm_parameter.sam-code-test] # 🤢
}

resource "aws_ssm_parameter" "sam-code-test" {
  name  = "db_password"
  type  = "String"
  value = var.db_password
}

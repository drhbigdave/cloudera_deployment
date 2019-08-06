data "aws_ssm_parameter" "vpc_id" {
  name = "default_vpc"
}

output "vpc_string" {
 value = "${data.aws_ssm_parameter.vpc_id.value}"
}

resource "aws_security_group" "rds1" {
  name        = "main_rds_sg"
  description = "Allow traffic only from public sg"
  vpc_id      = "${data.aws_ssm_parameter.vpc_id.value}"

  ingress {
    from_port   = 0
    to_port     = 3306
    protocol    = "TCP"
    security_groups = [
      "${var.pub_sg}",
      "${var.priv_sg}",
      ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS SG"
  }
}

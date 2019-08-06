data "aws_ssm_parameter" "home_ip" {
  name = "home_ip"
}

output "subnets_string" {
 value = "${data.aws_ssm_parameter.home_ip.value}"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "default_vpc"
}

output "vpc_string" {
 value = "${data.aws_ssm_parameter.vpc_id.value}"
}

resource "aws_security_group" "redshift" {
 count       = "${var.sg_count}"
 name        = "home_ip_redshift_sg"
 description = "for redshift cluster all allow home ip"
 vpc_id      = "${data.aws_ssm_parameter.vpc_id.value}"
 tags = {
    Name = "data-science"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.aws_ssm_parameter.home_ip.value}"] #you have to add the master sg, remove home ip
    self = true
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
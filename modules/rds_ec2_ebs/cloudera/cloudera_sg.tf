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

resource "aws_security_group" "cloudera_sg_pub" {
  name        = "home_ip_cloudera_sg"
  description = "hadoop home IP all traffic allow"
  vpc_id      = "${data.aws_ssm_parameter.vpc_id.value}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.aws_ssm_parameter.home_ip.value}"]
    self = true
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.cloudera_pub_sg_name_tag}"
  }
}
output "cloudera_sg_pub_id_output" {
   value = "${aws_security_group.cloudera_sg_pub.id}"
}
resource "aws_security_group" "cloudera_sg_priv" {
  name        = "internal_cloudera_sg"
  description = "for intra-VPC cloudera traffic"
  vpc_id      = "${data.aws_ssm_parameter.vpc_id.value}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
#    cidr_blocks = ["${data.aws_ssm_parameter.home_ip.value}"]
    self = true
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    self            = true
  }
  tags = {
    Name = "${var.cloudera_priv_sg_name_tag}"
  }
}
output "cloudera_sg_priv_id_output" {
   value = "${aws_security_group.cloudera_sg_priv.id}"
}

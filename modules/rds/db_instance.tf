data "aws_ssm_parameter" "db_pw" {
  name = "redshift_pw"
}

output "db_pw_string" {
 value = "${data.aws_ssm_parameter.db_pw.value}"
}
data "aws_ssm_parameter" "db_master" {
  name = "redshift_master"
}

output "db_master_string" {
 value = "${data.aws_ssm_parameter.db_master.value}"
}

resource "aws_db_instance" "cloudera_cdh_db" {
  identifier             = "${var.rds_instance_identifier}"
  allocated_storage      = "${var.allocated_storage}"
  storage_type           = "${var.storage_type}"
  engine                 = "${var.engine}"
  engine_version         = "${var.engine_version}"
  instance_class         = "${var.instance_class}"
  name                   = "${var.db_name}"
  username               = "${data.aws_ssm_parameter.db_master.value}"
  password               = "${data.aws_ssm_parameter.db_pw.value}"
  vpc_security_group_ids = ["${aws_security_group.rds1.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.subnet_group_1.id}"
  skip_final_snapshot    = "${var.skip_final_snapshot_bool}"
}

resource "aws_db_subnet_group" "subnet_group_1" {
  name        = "${var.rds_subnet_group_name}"
  description = "cloudera group of subnets"
  subnet_ids  = ["${var.rds_subnet_1}", "${var.rds_subnet_2}"]
}
output "rds_db_name" {
  value = "${aws_db_instance.cloudera_cdh_db.name}"
}
#output "rds_endpoint" {
#  value = "${aws_db_instance.cloudera_cdh_db.endpoint}"
#}
output "rds_port" {
  value = "${aws_db_instance.cloudera_cdh_db.port}"
}
output "rds_address" {
  value = "${aws_db_instance.cloudera_cdh_db.address}"
}

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

data "aws_iam_role" "redshift_role" {
  name = "${var.iam_roles}"
}

output "redshift_role" {
  value = "${data.aws_iam_role.redshift_role.arn}"
}

resource "aws_db_instance" "default" {
  depends_on             = ["aws_security_group.default"]
  identifier             = "${var.identifier}"
  allocated_storage      = "${var.storage}"
  engine                 = "${var.engine}"
  engine_version         = "${lookup(var.engine_version, var.engine)}"
  instance_class         = "${var.instance_class}"
  name                   = "${var.db_name}"
  username               = "${var.username}"
  password               = "${var.password}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.default.id}"
}

resource "aws_db_subnet_group" "default" {
  name        = "main_subnet_group"
  description = "Our main group of subnets"
  subnet_ids  = ["${aws_subnet.subnet_1.id}", "${aws_subnet.subnet_2.id}"]
}



resource "aws_redshift_cluster" "redshift_cluster" {
#  count              = "${var.count}" #use of requires splat notation, makes a list
  cluster_identifier = "${var.cluster_name}"
  database_name      = "${var.db_name}"
  master_username    = "${data.aws_ssm_parameter.db_master.value}"
  master_password    = "${data.aws_ssm_parameter.db_pw.value}"
  node_type          = "${var.node_type}"
  cluster_type       = "${var.cluster_type}"
  number_of_nodes    = "${var.nodes}"
  cluster_subnet_group_name = "${aws_redshift_subnet_group.redshift_subnet_group1.name}"
  enhanced_vpc_routing = "${var.enhanced}"
  iam_roles          = ["${data.aws_iam_role.redshift_role.arn}"]
  vpc_security_group_ids = ["${aws_security_group.redshift.id}"]
  skip_final_snapshot = "${var.final_snap}"
#  depends_on          = ["${aws_internet_gateway.internet_gw.id}"]
}
output "redshift_endpoint" {
  value = "${aws_redshift_cluster.redshift_cluster.endpoint}"
}
output "redshift_db_name" {
  value = "${aws_redshift_cluster.redshift_cluster.database_name}"
}
output "redshift_port" {
  value ="${aws_redshift_cluster.redshift_cluster.port}"
}
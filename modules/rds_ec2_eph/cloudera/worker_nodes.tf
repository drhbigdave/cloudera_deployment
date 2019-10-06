data "aws_iam_instance_profile" "cloudera_worker" {
  name = "cloudera_instance_role"
}
output "cloudera_worker_output" {
   value = "${data.aws_iam_instance_profile.cloudera_worker.name}"
}

data "template_file" "script_worker" {
  template = "${file("${path.module}/worker_install.tpl")}"
  vars = {
    redshift_usr_name = "${data.aws_ssm_parameter.db_master.value}"
    redshift_secret = "${data.aws_ssm_parameter.db_pw.value}"
    rds_address = "${var.rds_address}"
    rds_db_name = "${var.rds_db_name}"
    rds_port = "${var.rds_port}"
  }
}

resource "aws_instance" "cloudera_worker" {
  ami = "${var.amis}"
  instance_type = "${var.cloudera_worker_inst_type}"
  availability_zone = "${var.availability_zone}"
  count = "${var.cloudera_worker_count}"
#  depends_on = ["${aws_internet_gateway.internet_gw.id}"]
  subnet_id = "${var.subnet_priv}"
  associate_public_ip_address = false
  placement_group = "${aws_placement_group.cloudera.id}"
  root_block_device {
    volume_size = "${var.worker_root_vol_size}"
  }
# leaving this here in case the need for ephemeral comes up
  ephemeral_block_device {
    device_name = "/dev/sde"
    virtual_name = "ephemeral0"
  }
# leaving this here in case the need for non-ephemeral comes up
#  ebs_block_device {
#   volume_size    = 20,
#    device_name    = "/dev/sdf"
#  }
#  tags {
#    Name = "cloudera_worker${count.index}"
#  }

  #ssh key
  key_name = "${aws_key_pair.mykey.key_name}"

  #security group for all traffic within vpc
  vpc_security_group_ids = ["${aws_security_group.cloudera_sg_priv.id}"]

  # instance profile
  iam_instance_profile = "${data.aws_iam_instance_profile.cloudera_worker.name}"

  #bunch of bash stuff
  user_data = "${data.template_file.script_worker.rendered}"
}

output "worker_private_ip" {
  value = "${aws_instance.cloudera_worker.*.private_ip}"
}

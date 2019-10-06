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

data "aws_iam_instance_profile" "cloudera_master" {
  name = "cloudera_instance_role"
}
output "cloudera_master_output" {
   value = "${data.aws_iam_instance_profile.cloudera_master.name}"
}

resource "aws_placement_group" "cloudera" {
  name     = "cloudera-pg"
  strategy = "cluster"
}
output "placement_group_output" {
   value = "${aws_placement_group.cloudera.id}"
}

data "template_file" "script_master" {
  template = "${file("${path.module}/master_install.tpl")}"
  vars = {
    redshift_usr_name = "${data.aws_ssm_parameter.db_master.value}"
    redshift_secret = "${data.aws_ssm_parameter.db_pw.value}"
    rds_address = "${var.rds_address}"
    rds_db_name = "${var.rds_db_name}"
    rds_port = "${var.rds_port}"
  }
}

resource "aws_instance" "cloudera_master" {
  ami = "${var.amis}"
  instance_type = "${var.cloudera_master_inst_type}"
  availability_zone = "${var.availability_zone}"
  count = "${var.cloudera_master_count}"
  subnet_id = "${var.subnet_pub}"
  associate_public_ip_address = true
  placement_group = "${aws_placement_group.cloudera.id}"
  root_block_device {
    volume_size = "${var.master_root_vol_size}"
  }
# leaving here in case the need for ephemeral comes up, comment out on disuse
  ephemeral_block_device {
    device_name = "/dev/sde"
    virtual_name = "ephemeral0"
  }
# leaving here in case a non-ephemeral need comes up, comment out on disuse
#  ebs_block_device {
#   volume_size    = 20,
#    device_name    = "/dev/sdf"
#  }
#  tags {
#    Name = "cloudera_master${count.index}"
#  }

  #ssh key
  key_name = "${aws_key_pair.mykey.key_name}"

  #security group for all traffic from home IP
  vpc_security_group_ids = [
    "${aws_security_group.cloudera_sg_pub.id}",
    "${aws_security_group.cloudera_sg_priv.id}",
    ]

  # instance profile
  iam_instance_profile = "${data.aws_iam_instance_profile.cloudera_master.name}"

  # user data master_install
  user_data = "${data.template_file.script_master.rendered}"

}

output "master_public_ip" {
  value = "${aws_instance.cloudera_master.*.public_ip}"
}
#output "master_private_dns_fqdn" {
#   value = "${aws_instance.cloudera_master.*.private_dns}"
#}

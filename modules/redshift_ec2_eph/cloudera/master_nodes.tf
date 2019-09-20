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
data "template_file" "pgpass_file" {
  template = "${file("${path.module}/redshift_pgpass.tpl")}"
  vars {
    redshift_usr_name = "${data.aws_ssm_parameter.db_master.value}"
    redshift_secret = "${data.aws_ssm_parameter.db_pw.value}"
    redshift_end_point = "${var.redshift_cluster_endpoint}"
    redshift_db_name = "${var.redshift_db_name}"
    redshift_port = "${var.redshift_port}"
  }
}

data "template_file" "sql_script" {
  template = "${file("${path.module}/redshift_sql.sh.tpl")}"
  vars {
    redshift_usr_name = "${data.aws_ssm_parameter.db_master.value}"
    redshift_end_point = "${var.redshift_cluster_endpoint}"
    redshift_db_name = "${var.redshift_db_name}"
    redshift_port = "${var.redshift_port}"
  }
}

resource "aws_instance" "cloudera_master" {
  ami = "${var.amis}"
  instance_type = "${var.master_inst_type}"
  availability_zone = "${var.availability_zone}"
  count = "${var.cloudera_master_count}"
  subnet_id = "${var.subnet_pub}"
  associate_public_ip_address = true
  placement_group = "${aws_placement_group.cloudera.id}"
  ephemeral_block_device {
    device_name = "/dev/sde",
    virtual_name = "ephemeral0"
  }
# leaving this here in case the need for non-ephemeral comes up
#  ebs_block_device {
#   volume_size    = 20,
#    device_name    = "/dev/sdf"
#  }
  tags {
    Name = "cloudera_master${count.index}"
  }

  #ssh key
  key_name = "${aws_key_pair.mykey.key_name}"

  #security group for all traffic from home IP
  vpc_security_group_ids = [
    "${aws_security_group.cloudera_sg_pub.id}",
    "${aws_security_group.cloudera_sg_priv.id}",
    ]

  # instance profile
  iam_instance_profile = "${data.aws_iam_instance_profile.cloudera_master.name}"

  #bunch of bash stuff

  provisioner "file" {
    source = "${path.module}/script_master.sh"
    destination = "/home/maintuser/script_master.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x ~/script_master.sh",
      "sudo /home/maintuser/script_master.sh"
    ]
  }
  provisioner "file" {
    content      = "${data.template_file.pgpass_file.rendered}"
    destination = "/home/maintuser/.pgpass"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 0600 /home/maintuser/.pgpass"
      ]
  }
  provisioner "file" {
    content      = "${data.template_file.sql_script.rendered}"
    destination = "/home/maintuser/redshift_sql.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/maintuser/redshift_sql.sh",
      "sudo /home/maintuser/redshift_sql.sh"
      ]
  }

#  provisioner "file" {
#    source = "jupyter_notebook_config.py"
#    destination = "~/.jupyter/jupyter_notebook_config.py"
#  }


  connection {
    user = "${var.instance_username}"
    private_key = "${file("${var.path_to_privkey}")}"
  }
}

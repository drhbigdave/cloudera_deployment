data "aws_iam_instance_profile" "cloudera_worker" {
  name = "cloudera_instance_role"
}
output "cloudera_worker_output" {
   value = "${data.aws_iam_instance_profile.cloudera_worker.name}"
}

resource "aws_instance" "cloudera_worker" {
  ami = "${var.amis}"
  instance_type = "${var.cloudera_inst_type}"
  availability_zone = "${var.availability_zone}"
  count = "${var.cloudera_worker_count}"
#  depends_on = ["${aws_internet_gateway.internet_gw.id}"]
  subnet_id = "${var.subnet_priv}"
  associate_public_ip_address = false
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
    Name = "cloudera_worker${count.index}"
  }

  #ssh key
  key_name = "${aws_key_pair.mykey.key_name}"

  #security group for all traffic within vpc
  vpc_security_group_ids = ["${aws_security_group.cloudera_sg_priv.id}"]

  # instance profile
  iam_instance_profile = "${data.aws_iam_instance_profile.cloudera_worker.name}"

  #bunch of bash stuff
  user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install -y openscap-scanner scap-security-guide
        oscap xccdf eval --remediate --profile  standard --results scan-xccdf-results.xml /usr/share/xml/scap/ssg/content/ssg-amzn2-xccdf.xml
        yum install -y java-1.8.0-openjdk
        wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
        yum install -y ./epel-release-latest-*.noarch.rpm
        curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
        python get-pip.py
        pip install awscli
        pvcreate /dev/nvme1n1
        vgcreate /dev/VolGroup01 /dev/nvme1n1
        lvcreate -n cloudera -l 100%FREE VolGroup01
        sudo mkfs -t ext4  /dev/VolGroup01/cloudera
        mkdir /usr/local/cloudera
        printf "/dev/mapper/VolGroup01-cloudera /usr/local/cloudera  ext4    defaults        0 0" >> /etc/fstab
        mount -a
        EOF

#  provisioner "file" {
#    source = "${path.module}/script.sh"
#    destination = "~/script.sh"
#  }
#  provisioner "remote-exec" {
#    inline = [
#      "sudo chmod +x ~/script.sh",
#      "sudo ~/script.sh"
#    ]
#  }

#  provisioner "file" {
#    source = "${path.module}/script1.sh"
#    destination = "~/script1.sh"
#  }
#  provisioner "remote-exec" {
#    inline = [
#     "sudo chmod +x ~/script1.sh",
#      "sudo ~/script1.sh"
#    ]
#  }

#  provisioner "file" {
#    source = "jupyter_notebook_config.py"
#    destination = "~/.jupyter/jupyter_notebook_config.py"
#  }
#
#  provisioner "file" {
#    source = "scripts/script2.sh"
#    destination = "~/script2.sh"
#  }
#  provisioner "remote-exec" {
#    inline = [
#      "chmod +x ~/script2.sh",
#      "~/script2.sh"
#    ]
#  }

#  connection {
#    user = "${var.instance_username}"
#    private_key = "${file("${var.path_to_privkey}")}"
# }
}

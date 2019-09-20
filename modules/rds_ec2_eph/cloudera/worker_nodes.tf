data "aws_iam_instance_profile" "cloudera_worker" {
  name = "cloudera_instance_role"
}
output "cloudera_worker_output" {
   value = "${data.aws_iam_instance_profile.cloudera_worker.name}"
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
        printf "sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'" >> /etc/rc.d/rc.local
        printf "sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'" >> /etc/rc.d/rc.local
        printf "sysctl vm.swappiness=1" >> /etc/rc.d/rc.local
        yum -y install -y oracle-j2sdk1.7
        wget https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/cloudera-manager.repo -P /etc/yum.repos.d/
        yum install -y cloudera-manager-daemons cloudera-manager-server
        EOF
}

output "worker_private_ip" {
  value = "${aws_instance.cloudera_worker.*.private_ip}"
}

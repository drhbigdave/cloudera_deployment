#!/bin/bash

# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

# install oscap
sudo yum update -y

sudo yum install -y java-1.8.0-openjdk

#yum install -y wget
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y ./epel-release-latest-*.noarch.rpm
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
pip install awscli

# create lvm pv, lv and vg on datadisk
pvcreate /dev/nvme1n1
vgcreate /dev/VolGroup01 /dev/nvme1n1
lvcreate -n cloudera -l 100%FREE VolGroup01
sudo mkfs -t ext4  /dev/VolGroup01/cloudera


#  create second volume group and mount it in the gitlab install directory
# vgcreate /dev/VolGroup01 /dev/sdc #why is this here?
mkdir /usr/local/cloudera
printf "/dev/mapper/VolGroup01-cloudera /usr/local/cloudera  ext4    defaults        0 0" >> /etc/fstab
mount -a
touch /tmp/test1

yum install -y openscap-scanner scap-security-guide
oscap xccdf eval --remediate --profile  standard --results scan-xccdf-results.xml /usr/share/xml/scap/ssg/content/ssg-amzn2-xccdf.xml

printf "sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'" >> /etc/rc.d/rc.local
printf "sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'" >> /etc/rc.d/rc.local
printf "sysctl vm.swappiness=1" >> /etc/rc.d/rc.local

# at one point had installed psql for use with Redshift
#yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
#yum install -y postgresql11

wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.41.tar.gz
tar zxvf mysql-connector-java-5.1.41.tar.gz
mkdir -p /usr/share/java/
cp mysql-connector-java-5.1.41/mysql-connector-java-5.1.41-bin.jar /usr/share/java/mysql-connector-java.jar
yum -y install -y oracle-j2sdk1.7
wget https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/cloudera-manager.repo -P /etc/yum.repos.d/
yum install -y cloudera-manager-daemons cloudera-manager-server
yum install -y mysql

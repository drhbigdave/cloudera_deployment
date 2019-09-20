#!/bin/bash
pvcreate /dev/nvme1n1
vgcreate /dev/VolGroup01 /dev/nvme1n1
lvcreate -n cloudera -l 100%FREE VolGroup01
sudo mkfs -t ext4  /dev/VolGroup01/cloudera
mkdir /usr/local/cloudera
printf "/dev/mapper/VolGroup01-cloudera /usr/local/cloudera  ext4    defaults        0 0" >> /etc/fstab
mount -a
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y ./epel-release-latest-*.noarch.rpm
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
pip install awscli
yum install -y openscap-scanner scap-security-guide
oscap xccdf eval --remediate --profile  standard --results scan-xccdf-results.xml /usr/share/xml/scap/ssg/content/ssg-amzn2-xccdf.xml
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.41.tar.gz
tar zxvf mysql-connector-java-5.1.41.tar.gz
mkdir -p /usr/share/java/
cp mysql-connector-java-5.1.41/mysql-connector-java-5.1.41-bin.jar /usr/share/java/mysql-connector-java.jar
yum -y install -y oracle-j2sdk1.7
wget https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/cloudera-manager.repo -P /etc/yum.repos.d/
yum install -y cloudera-manager-daemons cloudera-manager-server
yum install -y mysql
setenforce 0 && firewall-offline-cmd --zone=public --add-service=https && setenforce 1
setenforce 0 && firewall-offline-cmd --zone=public --add-service=http && setenforce 1
setenforce 0 && firewall-offline-cmd --add-port=7180/tcp && setenforce 1
setenforce 0 && firewall-offline-cmd --add-port=7183/tcp && setenforce 1
setenforce 0 && firewall-offline-cmd --add-port=7182/tcp && setenforce 1
setenforce 0 && firewall-offline-cmd --add-port=9000/tcp && setenforce 1
systemctl restart firewalld
printf "sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'" >> /etc/rc.d/rc.local
printf "sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'" >> /etc/rc.d/rc.local
printf "sysctl vm.swappiness=1" >> /etc/rc.d/rc.local
aws s3 cp s3://cloudera-drh/rds_conf.sql /home/maintuser/
scmhost=$(curl -sS http://169.254.169.254/latest/meta-data/local-hostname)
mysql -h ${rds_address} -u ${redshift_usr_name} -P ${rds_port} -p${redshift_secret} < /home/maintuser/rds_conf.sql > ~/sql_output.txt
/usr/share/cmf/schema/scm_prepare_database.sh mysql -h ${rds_address} -u temp -ptemp --scm-host "$scmhost" scm scm_user scm_pwd
service cloudera-scm-server start

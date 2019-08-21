#!/bin/bash

#!/bin/bash
mysql -h ${rds_address} -u ${redshift_usr_name} -P ${rds_port} -p${redshift_secret} <<MY_QUERY
create database rman DEFAULT CHARACTER SET utf8;
grant all privileges  on rman.* TO 'rman_user' IDENTIFIED BY 'rman_pwd';
create database hivey DEFAULT CHARACTER SET utf8;
GRANT ALL PRIVILEGES ON hivey.* TO 'hivey_user' IDENTIFIED BY 'hivey_pwd';
create database oozie DEFAULT CHARACTER SET utf8;
grant all privileges  on oozie.* TO 'oozie_user' IDENTIFIED BY 'oozie_pwd';
create database huey DEFAULT CHARACTER SET utf8;
grant all privileges  on huey.* TO 'huey_user' IDENTIFIED BY 'huey_pwd';
create database sentryy DEFAULT CHARACTER SET utf8;
grant all privileges  on sentryy.* TO 'sentry_user' IDENTIFIED BY 'sentry_pwd';
grant all on `%`.* to 'temp'@'%' IDENTIFIED by 'temp' with grant option;
grant all privileges  on `%`.* to 'scm_user'@'%' IDENTIFIED BY 'scm_pwd';
grant all on `%`.* to 'scm_user'@'%' identified by 'scm_pwd' with grant option;
grant all privileges  on `%`.* TO 'temp'@'%' IDENTIFIED BY 'temp';
Flush privileges;
exit
MY_QUERY
#psql "host=cloudera-rds.cznlqqqj7fdq.us-east-1.rds.amazonaws.com user=redshift dbname=cloudera_cdh port=3306"
#mysql -h ${rds_address} -u ${redshift_usr_name} -P ${rds_port} -p${redshift_secret} ${rds_db_name}

sudo /usr/share/cmf/schema/scm_prepare_database.sh mysql -h ${rds_address} -u temp -ptemp --scm-host  scm scm_user scm_pwd

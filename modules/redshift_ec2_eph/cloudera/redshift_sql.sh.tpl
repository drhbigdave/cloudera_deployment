#!/bin/bash

#!/bin/bash
psql -h redshift1.ccmwpu7us3rn.us-east-1.redshift.amazonaws.com -U redshift -d redshiftdb -p 5439 <<MY_QUERY
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


#psql -h redshift1.ccmwpu7us3rn.us-east-1.redshift.amazonaws.com -U redshift -d redshiftdb -p 5439
#redshift1.ccmwpu7us3rn.us-east-1.redshift.amazonaws.com:5439:redshiftdb:redshift:
#psql "host=${redshift_end_point} user=${redshift_usr_name} dbname=${redshift_db_name} port=${redshift_port}"
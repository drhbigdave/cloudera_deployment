#!/bin/bash

# sleep until instance is ready



#wget https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh -O ~/anaconda.sh
#bash ~/anaconda.sh -b -p $HOME/anaconda3
#export PATH="$HOME/anaconda3/bin:$PATH"

#mkdir $HOME/certs
#mkdir $HOME/.jupyter

#wget https://downloads.lightbend.com/scala/2.12.6/scala-2.12.6.rpm

#sudo yum install -y scala-2.12.6.rpm

sudo $HOME/anaconda3/bin/conda install -y pip

sudo $HOME/anaconda3/bin/pip install -q py4j

sudo $HOME/anaconda3/bin/pip install -q boto3

wget https://s3.amazonaws.com/bits-drh/parquet/part-00000-213487d5-5ba9-4460-9f8d-012610916709-c000.snappy.parquet -O ~/s3test

wget https://www-us.apache.org/dist/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz

sudo tar xvf spark-2.4.0-bin-hadoop2.7.tgz

sudo mv spark-2.4.0-bin-hadoop2.7/* /usr/local/spark
sudo printf "export PATH=/"$PATH:/usr/local/spark/bin/"" > /home/maintuser/.bashrc

#sudo openssl req -x509 -nodes -days 365 -newkey rsa:1024 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=*" -keyout /home/ec2-user/certs/mycert.pem -out /home/ec2-user/certs/mycert.pem




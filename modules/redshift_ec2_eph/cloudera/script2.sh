#!/bin/bash


export PATH=$PATH:$HOME/anaconda3/bin
export SPARK_HOME='/home/ec2-user/spark-2.4.0-bin-hadoop2.7'
export PATH=$SPARK_HOME:$PATH
export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH

#jupyter notebook 

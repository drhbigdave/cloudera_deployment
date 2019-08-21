variable "environment" {}
variable "amis" {
	description = "used in instance.tf for cloudera instance resource"
}
variable "cloudera_master_inst_type" {}
variable "cloudera_worker_inst_type" {}
variable "cloudera_master_count" {}
variable "cloudera_worker_count" {}
variable "availability_zone" {}
variable "instance_username" {}
variable "path_to_privkey" {}
variable "path_to_pubkey" {}
variable "sg_count" {}
variable "subnet_pub" {}
variable "subnet_priv" {}
variable "cloudera_priv_sg_name_tag" {}
variable "cloudera_pub_sg_name_tag" {}
#variable "rds_cluster_endpoint" {}
variable "rds_address" {}
variable "rds_db_name" {}
variable "rds_port" {}
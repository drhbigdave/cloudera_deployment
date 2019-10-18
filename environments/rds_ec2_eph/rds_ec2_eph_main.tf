module "cloudera" {
  sg_count           = 1
  source             = "../../modules/rds_ec2_eph/cloudera/"
  environment        = "dev"
  amis               = "ami-0a3bc2f18f51ef379"
  cloudera_master_inst_type = "t3a.medium"
  cloudera_worker_inst_type = "c5d.large" #"r5ad.large"
  cloudera_master_count = 1
  cloudera_worker_count = 1
  #master_root_vol_size = 65
  worker_root_vol_size = 65
  availability_zone  = "us-east-1f" #az for all cloudera resources, 1f required for r5ad inst type
  instance_username  = "maintuser"
  path_to_privkey    = "~/projects/tf_keys/spark-mykey"
  path_to_pubkey     = "~/projects/tf_keys/spark-mykey.pub"
  subnet_pub    = "${module.network.external_subnet_output}"
  subnet_priv    = "${module.network.internal_subnet_output}"
  cloudera_pub_sg_name_tag = "cloudera_pub"
  cloudera_priv_sg_name_tag = "cloudera_priv"
#  rds_cluster_endpoint = "${element(split(":", module.rds.rds_endpoint),0)}"
  rds_address = "${module.rds.rds_address}"
  rds_db_name = "${module.rds.rds_db_name}"
  rds_port = "${module.rds.rds_port}"
#  worker_private_dns = "${module.cloudera.master_private_dns_fqdn}"
#  master_internal_dns = "${module.cloudera.master_private_dns_fqdn}"
}
module "rds" {
  source             = "../../modules/rds_ec2_eph/rds/"
  allocated_storage  = "20"
  storage_type       = "gp2"
  engine             = "mysql"
  engine_version     = "5.6.35"
  instance_class     = "db.t3.medium"
  db_name            = "cloudera_cdh"
  rds_subnet_group_name = "cloudera_subnet_group"
  rds_instance_identifier = "cloudera-rds"
  rds_subnet_1 = "${module.network.internal_rds_subnet_1_output}"
  rds_subnet_2 = "${module.network.internal_rds_subnet_2_output}"
  pub_sg              = "${module.cloudera.cloudera_sg_pub_id_output}"
  priv_sg             = "${module.cloudera.cloudera_sg_priv_id_output}"
  rds_sg_name_tag     = "rds_instance_sg"
  skip_final_snapshot_bool = true
}
module "network" {
  source = "../../modules/rds_ec2_eph/network"
  availability_zone_1  = "us-east-1f" #az all used resources in
  availability_zone_2  = "us-east-1a" #az for rds replica
}
output "master_public_ip_env" {
  value = "${module.cloudera.master_public_ip}"
}
output "worker_private_ip_env" {
  value = "${module.cloudera.worker_private_ip}"
}
output "rds_address_env" {
  value = "${module.rds.rds_address}"
}

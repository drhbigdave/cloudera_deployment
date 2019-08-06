module "cloudera" {
  sg_count           = 1
  source             = "../../modules/cloudera/"
  environment        = "dev"
  amis               = "ami-0574062183ccc507a"
  cloudera_inst_type      = "c5d.large"
  cloudera_master_count = 1
  cloudera_worker_count = 1
  availability_zone  = "us-east-1a"
  instance_username  = "maintuser"
  path_to_privkey    = "~/projects/tf_keys/spark-mykey"
  path_to_pubkey     = "~/projects/tf_keys/spark-mykey.pub"
  subnet_pub    = "${module.network.external_subnet_output}"
  subnet_priv    = "${module.network.internal_subnet_output}"
#  redshift_cluster_endpoint = "${element(split(":", module.redshift.redshift_endpoint),0)}"
#  redshift_db_name = "${module.rds.redshift_db_name}"
#  redshift_port = "${module.redshift.redshift_port}"
}
module "rds" {
  source             = "../../modules/rds/"
  allocated_storage  = "20"
  storage_type       = "gp2"
  engine             = "mysql"
  engine_version     = "5.6.35"
  instance_class     = "db.t3.medium"
  db_name            = "cloudera_cdh"
  rds_subnet_group_name = "cloudera_subnet_group"
  rds_instance_identifier = "cloudera_rds"
  rds_subnet_1 = "${module.network.internal_rds_subnet_1_output}"
  rds_subnet_2 = "${module.network.internal_rds_subnet_2_output}"
  pub_sg              = "${module.cloudera.cloudera_sg_pub_id_output}"
  priv_sg             = "${module.cloudera.cloudera_sg_priv_id_output}"
}
module "network" {
  source = "../../modules/network"
  availability_zone_1  = "us-east-1a"
  availability_zone_2  = "us-east-1f"
}
output "endpoint_var" {
  value = "substr(${module.rds.rds_endpoint},0, -5)"
}

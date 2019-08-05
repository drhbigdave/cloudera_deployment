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
  redshift_cluster_endpoint = "${element(split(":", module.redshift.redshift_endpoint),0)}"
  redshift_db_name = "${module.redshift.redshift_db_name}"
  redshift_port = "${module.redshift.redshift_port}"
}
module "rds" {
  count              = 1
  sg_count           = 1
  source             = "../../modules/redshift/"
  cluster_name       = "redshift1"
  db_name            = "redshiftdb"
  node_type          = "dc2.large"
  cluster_type       = "multi-node"
  nodes              = 2
  subnet_group_name  = "group1"
  enhanced           = true
  iam_roles          = "udemy_pipeline"
  final_snap         = true
  subnet    = "${module.network.external_subnet_output}"
  availability_zone  = "us-east-1a" #improve
}
module "network" {
  source = "../../modules/network"
  availability_zone  = "us-east-1a"
}
output "endpoint_var" {
  value = "substr(${module.redshift.redshift_endpoint},0, -5)"
}
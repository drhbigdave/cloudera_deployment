module "prod-spark" {
  source             = "../../spark"
  environment        = "prod"
  aws_region         = "us-east-1"
  instance_type      = "t2.medium"
  availability_zone  = "us-east-1a"
  instance_username  = "${var.instance_username}"
  home_ip            = "${var.home_ip}"
  vpc_id             = "${var.vpc_id}"
  path_to_privkey    = "../../../../../tf_keys/mykey"
  path_to_pubkey     = "../../../../../tf_keys/mykey.pub"
}
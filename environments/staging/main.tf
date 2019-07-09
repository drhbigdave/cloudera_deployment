module "staging-spark" {
  source             = "../../spark"
  environment        = "staging"
  amis               = "ami-04681a1dbd79675a5"
  instance_type      = "t2.medium"
  availability_zone  = "us-east-1a"
  count              = 1
  vpc_id             = "vpc-11882474"
  home_ip            = "73.163.104.95/32"
  instance_username  = "ec2-user"
  path_to_privkey    = "../../../tf_keys/staging-mykey"
  path_to_pubkey     = "../../../tf_keys/staging-mykey.pub"
}
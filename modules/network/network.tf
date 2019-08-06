# sensitive parameter store values

data "aws_ssm_parameter" "vpc_id" {
  name = "default_vpc"
}

output "vpc_string" {
 value = "${data.aws_ssm_parameter.vpc_id.value}"
}

data "aws_ssm_parameter" "vpc_s3_endpoint" {
  name = "s3_endpoint"
}

output "vpce_string" {
 value = "${data.aws_ssm_parameter.vpc_s3_endpoint.value}"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${data.aws_ssm_parameter.vpc_id.value}"
  service_name = "com.amazonaws.us-east-1.s3"
}
##
resource "aws_subnet" "external" {
  vpc_id     = "${data.aws_ssm_parameter.vpc_id.value}"
  cidr_block = "172.31.17.0/24"
  availability_zone = "${var.availability_zone_1}"

  tags = {
    Name = "cloudera-external"
  }
}

resource "aws_route_table" "us-east-1a-public" {
    vpc_id = "${data.aws_ssm_parameter.vpc_id.value}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.int_gw.id}"
    }

    tags {
        Name = "Cloudera Public Subnet"
    }
}

resource "aws_route_table_association" "us-east-1a-public" {
    subnet_id = "${aws_subnet.external.id}"
    route_table_id = "${aws_route_table.us-east-1a-public.id}"
}
resource "aws_vpc_endpoint_route_table_association" "external" {
    route_table_id  = "${aws_route_table.us-east-1a-public.id}"
    vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
}

output "external_subnet_output" {
   value = "${aws_subnet.external.id}"
}

resource "aws_internet_gateway" "int_gw" {
  vpc_id = "${data.aws_ssm_parameter.vpc_id.value}"

  tags = {
    Name = "cloudera"
  }
}

#output "internet_gw" {
#	value = "${data.aws_internet_gateway.internet_gw.id}"
#}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.external.id}"
  depends_on = ["aws_internet_gateway.int_gw"]

  tags = {
    Name = "cloudera"
  }
}
## ^ end external stuff: subnet, route table, route table assoc, igw, nat gw,

## start internal stuff

resource "aws_subnet" "internal_instances" {
    vpc_id     = "${data.aws_ssm_parameter.vpc_id.value}"
    cidr_block = "172.31.18.0/24"
    availability_zone = "${var.availability_zone_1}"

  tags = {
    Name = "cloudera-internal"
  }
}

output "internal_subnet_output" {
   value = "${aws_subnet.internal_instances.id}"
}


resource "aws_route_table" "us-east-private" {
    vpc_id = "${data.aws_ssm_parameter.vpc_id.value}"

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
    }

    tags {
        Name = "Cloudera Private Subnet route table"
    }
}

resource "aws_route_table_association" "us-east-private_assoc1" {
    subnet_id = "${aws_subnet.internal_instances.id}"
    route_table_id = "${aws_route_table.us-east-private.id}"
}

resource "aws_vpc_endpoint_route_table_association" "internal" {
    route_table_id  = "${aws_route_table.us-east-private.id}"
    vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
}

## RDS Private subnets

resource "aws_subnet" "internal_rds_subnet_1" {
    vpc_id     = "${data.aws_ssm_parameter.vpc_id.value}"
    cidr_block = "172.31.19.0/27"
    availability_zone = "${var.availability_zone_1}"

  tags = {
    Name = "cloudera-internal-rds-1a"
  }
}
output "internal_rds_subnet_1_output" {
   value = "${aws_subnet.internal_rds_subnet_1.id}"
}
resource "aws_route_table_association" "us-east-private_assoc2" {
    subnet_id = "${aws_subnet.internal_rds_subnet_1.id}"
    route_table_id = "${aws_route_table.us-east-private.id}"
}

resource "aws_subnet" "internal_rds_subnet_2" {
    vpc_id     = "${data.aws_ssm_parameter.vpc_id.value}"
    cidr_block = "172.31.19.32/27"
    availability_zone = "${var.availability_zone_2}"

  tags = {
    Name = "cloudera-internal-rds-1f"
  }
}
output "internal_rds_subnet_2_output" {
   value = "${aws_subnet.internal_rds_subnet_2.id}"
}
resource "aws_route_table_association" "us-east-private_assoc3" {
    subnet_id = "${aws_subnet.internal_rds_subnet_2.id}"
    route_table_id = "${aws_route_table.us-east-private.id}"
}

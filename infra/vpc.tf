module "vpc_subnets" {
  name                 = "${var.project}-${terraform.env}-vpc"
  source               = "./modules/vpc"
  environment          = "${terraform.env}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
  nat_cidr             = ["10.0.5.0/24", "10.0.6.0/24"]
  igw_cidr             = "10.0.8.0/24"
  azs                  = ["eu-west-2a", "eu-west-2b"]
  project              = "${var.project}"
  owner                = "${var.owner}"
  costcenter           = "${var.costcenter}"
}

resource "aws_security_group" "all" {
  name = "all"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${module.vpc_subnets.vpc_id}"

  tags {
    Environment = "${terraform.env}"
    Project     = "${var.project}"
    Owner       = "${var.owner}"
    CostCenter  = "${var.costcenter}"
    managed_by  = "terraform"
    service     = "${var.project}"
  }
}

resource "aws_security_group" "rds" {
  name = "rds"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = "${var.trusted_cidrs}"
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc_subnets.cidr}"]
  }

  vpc_id = "${module.vpc_subnets.vpc_id}"

  tags {
    Environment = "${terraform.env}"
    Project     = "${var.project}"
    Owner       = "${var.owner}"
    CostCenter  = "${var.costcenter}"
    managed_by  = "terraform"
    service     = "${var.project}"
  }
}

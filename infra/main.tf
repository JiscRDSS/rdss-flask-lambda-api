provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "rdss-taxonomy-api-remote-state"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}

####################
# VPC
####################
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
  service              = "${var.service}"
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
    service     = "${var.service}"
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
    service     = "${var.service}"
  }
}

####################
# RDS
####################
resource "random_id" "random_string" {
  byte_length = 8
}

module "rds_instance" {
  source                = "./modules/rds"
  rds_instance_name     = "${var.project}-${terraform.env}"
  rds_is_multi_az       = "true"
  rds_storage_type      = "gp2"
  rds_allocated_storage = 10
  rds_engine_type       = "postgres"
  rds_instance_class    = "${var.db_instance_type}"
  rds_database_user     = "${var.db_user}"
  rds_database_password = "${var.db_pass}"
  rds_security_group_id = "${aws_security_group.rds.id}"
  rds_db_name           = "${var.db_name}"

  // external access required for migrations
  rds_publicly_accessible = true

  /* Uncomment for restoring snapshots */
  rds_final_snapshot_identifier = "${var.project}-${terraform.env}-final"

  db_parameter_group    = "${aws_db_parameter_group.postgres_parameter_group.name}"
  subnet_az1            = "${element(module.vpc_subnets.public_subnet_ids, 1)}"
  subnet_az2            = "${element(module.vpc_subnets.public_subnet_ids, 2)}"
  rds_backup_ret        = "7"
  rds_backup_window     = "01:00-02:00"
  rds_storage_encrypted = "false"
  project               = "${var.project}"
  owner                 = "${var.owner}"
  costcenter            = "${var.costcenter}"
  service               = "${var.service}"
  environment           = "${terraform.env}"
}

resource "aws_db_parameter_group" "postgres_parameter_group" {
  name        = "${var.project}-${terraform.env}-postgres-pg"
  family      = "postgres${var.postgres_version}"
  description = "RDS postgres parameter group"

  tags {
    Name        = "${var.project}-${terraform.env}-postgres-pg"
    Environment = "${terraform.env}"
    Project     = "${var.project}"
    Owner       = "${var.owner}"
    CostCenter  = "${var.costcenter}"
    managed_by  = "terraform"
    service     = "${var.service}"
  }
}

####################
# API
####################
module "api" {
  name       = "${module.lambda.name}"
  source     = "./modules/api"
  method     = "ANY"
  lambda     = "${module.lambda.name}"
  lambda_arn = "${module.lambda.arn}"
  region     = "${var.region}"
  account_id = "${var.account_id}"
  stage_name = "${terraform.env}"
}

####################
# Lambda
####################
module "lambda" {
  source        = "./modules/lambda"
  s3_bucket     = "${aws_s3_bucket.lambda_repo.bucket}"
  s3_key        = "${var.lambda_filename}"
  hash          = "${data.aws_s3_bucket_object.lambda_dist_hash.etag}"
  function_name = "${var.project}-${terraform.env}-${var.lambda_function_name}"
  handler       = "${var.lambda_handler}"
  runtime       = "${var.lambda_runtime}"
  role          = "${aws_iam_role.lambda_role.arn}"
  database_uri  = "${module.rds_instance.url}"

  subnet_ids         = ["${module.vpc_subnets.nat_subnet_id}"]
  security_group_ids = ["${aws_security_group.all.id}"]
}

resource "aws_s3_bucket" "lambda_repo" {
  bucket = "lambda_repo-${var.project}-${terraform.env}"
  region = "${var.region}"
}

resource "aws_s3_bucket_object" "lambda_dist" {
  bucket = "${aws_s3_bucket.lambda_repo.bucket}"
  key    = "${var.lambda_filename}"
  source = "${var.lambda_filename}"
  etag   = "${md5(file(var.lambda_filename))}"
}

data "aws_s3_bucket_object" "lambda_dist_hash" {
  bucket     = "${aws_s3_bucket.lambda_repo.bucket}"
  key        = "${var.lambda_filename}"
  depends_on = ["aws_s3_bucket_object.lambda_dist"]
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.project}-${terraform.env}-${var.lambda_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc" {
  name = "${aws_iam_role.lambda_role.name}-vpc"
  role = "${aws_iam_role.lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "logs" {
  name = "${aws_iam_role.lambda_role.name}-logs"
  role = "${aws_iam_role.lambda_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

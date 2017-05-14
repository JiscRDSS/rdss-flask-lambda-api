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
  bucket = "${var.prefix}-${var.project}-${terraform.env}"
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
  name = "${var.prefix}-${terraform.env}-${var.lambda_name}-role"

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

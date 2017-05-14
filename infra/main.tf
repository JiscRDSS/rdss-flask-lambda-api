provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "rdds-flask-lambda-api-remote-state"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}

variable "account_id" {}

variable "project" {
  description = "Project name for tags and resource naming"
  default     = "flask-lambda-api"
}

variable "owner" {
  description = "Contact person responsible for the resource"
  default     = "alan.mackenzie@digirati.com"
}

variable "costcenter" {
  description = "Cost Center tag"
  default     = "RDSS"
}

variable "service" {
  description = "Service name"
  default     = "rdss"
}

variable "region" {
  default = "eu-west-2"
}

####################
# lambda
####################
variable "lambda_name" {
  default = "flask-lambda"
}

variable "lambda_runtime" {
  default = "python3.6"
}

variable "lambda_filename" {}

variable "lambda_function_name" {
  default = "HttpServer"
}

variable "lambda_handler" {
  default = "run.app"
}

####################
# api gateway
####################
variable "aws_api_gateway_name" {
  default = "flask-lambda-api"
}

####################
# rds
####################
variable "availability_zones" {
  description = "List of availability zones."

  type = "list"

  default = [
    "eu-west-2a",
    "eu-west-2b",
  ]
}

variable "postgres_version" {
  default = "9.5"
}

variable "db_instance_type" {
  default = "db.t2.small"
}

variable "db_name" {
  description = "Name of database."
}

variable "db_user" {
  description = "Username for the database."
}

variable "db_pass" {
  description = "Password for the database."
}

variable "trusted_cidrs" {
  description = "Access to DB for running migrations"
  type        = "list"
}

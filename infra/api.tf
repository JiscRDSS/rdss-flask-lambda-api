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

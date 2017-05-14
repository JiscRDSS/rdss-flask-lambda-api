resource "random_id" "random_string" {
  byte_length = 8
}

module "rds_instance" {
  source                = "./modules/rds"
  rds_instance_name     = "${var.prefix}-rds-${terraform.env}"
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
  rds_final_snapshot_identifier = "${var.prefix}-${terraform.env}-rds-final"

  # rds_snapshot_identifier = "${var.prefix}-${terraform.env}-rds-final"

  db_parameter_group    = "${aws_db_parameter_group.postgres_parameter_group.name}"
  subnet_az1            = "${element(module.vpc_subnets.public_subnet_ids, 1)}"
  subnet_az2            = "${element(module.vpc_subnets.public_subnet_ids, 2)}"
  rds_backup_ret        = "7"
  rds_backup_window     = "01:00-02:00"
  rds_storage_encrypted = "false"
  project               = "${var.project}"
  owner                 = "${var.owner}"
  costcenter            = "${var.costcenter}"
  environment           = "${terraform.env}"
}

resource "aws_db_parameter_group" "postgres_parameter_group" {
  name        = "${var.prefix}-${terraform.env}-rds-postgres-pg"
  family      = "postgres${var.postgres_version}"
  description = "RDS postgres parameter group"

  tags {
    Name        = "${var.project}-${terraform.env}-rds-postgres-pg"
    Environment = "${terraform.env}"
    Project     = "${var.project}"
    Owner       = "${var.owner}"
    CostCenter  = "${var.costcenter}"
    managed_by  = "terraform"
    service     = "${var.project}"
  }
}

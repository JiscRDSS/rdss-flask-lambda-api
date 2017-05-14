resource "aws_db_instance" "rds_instance" {
  name                      = "${var.rds_db_name}"
  identifier                = "${var.rds_instance_name}"
  allocated_storage         = "${var.rds_allocated_storage}"
  engine                    = "${var.rds_engine_type}"
  instance_class            = "${var.rds_instance_class}"
  username                  = "${var.rds_database_user}"
  password                  = "${var.rds_database_password}"
  vpc_security_group_ids    = ["${var.rds_security_group_id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.rds_subnet_group.name}"
  parameter_group_name      = "${var.db_parameter_group}"
  multi_az                  = "${var.rds_is_multi_az}"
  storage_type              = "${var.rds_storage_type}"
  backup_retention_period   = "${var.rds_backup_ret}"
  backup_window             = "${var.rds_backup_window}"
  storage_encrypted         = "${var.rds_storage_encrypted}"
  snapshot_identifier       = "${var.rds_snapshot_identifier}"
  final_snapshot_identifier = "${var.rds_final_snapshot_identifier}"
  publicly_accessible       = "${var.rds_publicly_accessible}"

  tags {
    Name        = "${var.project}-${terraform.env}-rds"
    Environment = "${terraform.env}"
    Project     = "${var.project}"
    Owner       = "${var.owner}"
    CostCenter  = "${var.costcenter}"
    managed_by  = "terraform"
    service     = "${var.project}"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.rds_instance_name}-${terraform.env}-subnet"
  description = "${var.rds_instance_name} subnet group."
  subnet_ids  = ["${var.subnet_az1}", "${var.subnet_az2}"]

  tags {
    Name        = "${var.project}-${terraform.env}-rds-subg"
    Environment = "${terraform.env}"
    Project     = "${var.project}"
    Owner       = "${var.owner}"
    CostCenter  = "${var.costcenter}"
    managed_by  = "terraform"
    service     = "${var.project}"
  }
}

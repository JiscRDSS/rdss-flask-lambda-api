variable "rds_instance_name" {
  description = "Name of the RDS instance to be created."
}

variable "rds_is_multi_az" {
  description = "True if the RDS instance should span multiple AZ's"
  default     = "false"
}

variable "rds_storage_type" {
  description = "Storage type to be used for RDS."
  default     = "standard"
}

variable "rds_allocated_storage" {
  description = "GB's of storage to be allocated to RDS instance."
  default     = "20"
}

variable "rds_engine_type" {
  description = "Database engine to use for RDS instance."
}

variable "rds_backup_ret" {
  description = "Number of days to retain backup snapshots."
  default     = "7"
}

variable "rds_backup_window" {
  description = "Times to perform backup snapshots."
  default     = "01:00-02:00"
}

variable "rds_instance_class" {
  description = "Instance class for RDS."
}

variable "rds_database_user" {
  description = "Database user for the RDS instance."
}

variable "rds_database_password" {
  description = "Database password for RDS instance."
}

variable "rds_security_group_id" {
  description = "ID of security group to assign to RDS."
}

variable "rds_storage_encrypted" {
  description = "True if the storage should be encrypted."
  default     = true
}

variable "db_parameter_group" {
  description = "Database parameter groups."
}

variable "subnet_az1" {
  description = "Subnet for Availabiltiy Zone 1"
}

variable "subnet_az2" {
  description = "Subnet for Availability Zone 2"
}

variable "rds_snapshot_identifier" {
  description = "Identifier to be used for restoring from snapshot. Leave blank for a fresh instance."
  default     = ""
}

variable "rds_final_snapshot_identifier" {
  description = "Identifier to be used for final snapshot when destroying DB. Leave blank for no snapshot."
  default     = false
}

variable "rds_db_name" {
  description = "Name of the database to create."
  default     = ""
}

variable "rds_publicly_accessible" {
  description = "Name of the database to create."
  default     = false
}

variable "project" {}
variable "service" {}
variable "owner" {}
variable "environment" {}
variable "costcenter" {}

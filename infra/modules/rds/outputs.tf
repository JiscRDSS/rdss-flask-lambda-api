output "rds_instance_id" {
  value = "${aws_db_instance.rds_instance.id}"
}

output "rds_instance_address" {
  value = "${aws_db_instance.rds_instance.address}"
}

output "url" {
  value = "postgres://${aws_db_instance.rds_instance.username}:${aws_db_instance.rds_instance.password}@${aws_db_instance.rds_instance.address}/${aws_db_instance.rds_instance.name}"
}

output "subnet_group_id" {
  value = "${aws_db_subnet_group.rds_subnet_group.id}"
}

output "db_url" {
  value = "${module.rds_instance.url}"
}

output "api_url" {
  value = "${module.api.api_url}"
}

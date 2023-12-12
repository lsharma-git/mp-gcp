variable "project_id" {}
variable "region" { default = "europe-west3" }
variable "zone" { default = "europe-west3-c" }
variable "environment" { default = "dev" }
variable "backend_config_map" {
  default     = {}
  description = "Config for frontend pipeline consumption"
}
variable "ip_cidr_range" {
  default = "192.168.1.0/24"
}
variable "project_creation_with_new_folder" {
  type    = bool
  default = true
}
variable "sa_role" {
  type = list(string)
  default = [
    "roles/artifactregistry.admin",
    "roles/run.admin",
    "roles/secretmanager.secretAccessor"
  ]
}
variable "service_name" {
  type    = string
  default = "mp"
}
variable "cloudrun_name" {
  type    = string
  default = "cloudrun-service-project1"
}
variable "min_instances" {
  type    = number
  default = 1
}
variable "loadbalancer_name" {
  type    = string
  default = "lb-service-project1"
}
variable "managed_ssl_certificate_domains" {
  type    = list(string)
  default = ["managed_ssl_certificate_domains"]
}

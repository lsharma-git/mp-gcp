variable "project_id" {}
variable "region" {
  description = "Region detail in which infrastructure would deploy"
  type        = string
  default     = "europe-west3"
}
variable "zone" {
  description = "Zone detail in which infrastructure would deploy"
  type        = string
  default     = "europe-west3-c"
}
variable "environment" {
  type        = string
  description = "Environment of the infrastructure"
  default     = "dev"
}
variable "backend_config_map" {
  description = "Config for frontend pipeline consumption"
  type        = map(string)
  default     = {}
}
variable "ip_cidr_range" {
  default = "192.168.1.0/24"
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
variable "min_instances" {
  type    = number
  default = 1
}
variable "max_instances" {
  type    = number
  default = 2
}
variable "loadbalancer_name" {
  type    = string
  default = "lb-service-project1"
}
variable "managed_ssl_certificate_domains" {
  type    = list(string)
  default = ["example.com"]
}
variable "sa_display_name" {
  type    = string
  default = "Service Account created by terraform"
}

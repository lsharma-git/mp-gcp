variable "project_id" { }
variable "region" { default = "europe-west3" }
variable "zone" { default = "europe-west3-c" }

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
  type    = list(string)
  default = ["roles/artifactregistry.admin"]
}
variable "cloudrun_name" {
  type    = string
  default = "cloudrun-service-project1"
}
variable "min_instances" {
  type    = number
  default = 1
}

module "network" {
  source        = "../modules/network/vpc"
  name          = var.cloudrun_name
  ip_cidr_range = var.ip_cidr_range
}

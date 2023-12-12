module "network" {
  source        = "../modules/network/vpc"
  name          = var.cloudrun_name
  ip_cidr_range = var.ip_cidr_range
}

# resource "google_vpc_service_perimeter" "default" {
#   name        = "vpc-perimeter"
#   description = "VPC perimeter for Cloud Run and Artifact Registry"
#   network     = module.network.vpc_name
# }

# resource "google_access_context_manager_access_level" "default" {
#   parent = 
#   name        = "vpc-perimeter-access-level"
#   description = "Access level for Cloud Run and Artifact Registry"
#   title       = "VPC Perimeter Access"
#   basic_bindings {
#     role = "roles/run.admin"
#     members = [
#       "serviceAccount:vpc-perimeter-sa@${var.project}.iam.gserviceaccount.com",
#     ]
#   }
#   basic_bindings {
#     role = "roles/artifactregistry.writer"
#     members = [
#       "serviceAccount:vpc-perimeter-sa@${var.project}.iam.gserviceaccount.com",
#     ]
#   }
# }

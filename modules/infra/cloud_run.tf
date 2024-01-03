# # Enables the Cloud Run API service in the project
# resource "google_project_service" "cloudrun_api" {
#   project            = var.project_id
#   service            = "run.googleapis.com"
#   disable_on_destroy = true
# }

# # Create Cloudrun Service 
# resource "google_cloud_run_v2_service" "cloudrun" {
#   depends_on = [
#     google_project_service.cloudrun_api,
#     google_artifact_registry_repository.my-repo,
#     module.network
#   ]
#   name         = "${var.service_name}-cloudrun"
#   location     = var.region
#   project      = var.project_id
#   launch_stage = "BETA"

#   template {

#     scaling {
#       min_instance_count = var.min_instances
#       max_instance_count = var.max_instances
#     }
#     containers {
#       image = "europe-west3-docker.pkg.dev/dgcp-sandbox-lalit-sharma/my-customnginx/customnginx"

#       env {
#         name  = "_SERVICE_NAME"
#         value = var.service_name
#       }
#       env {
#         name  = "_PROJECT_ID"
#         value = var.project_id
#       }
#       ports {
#         container_port = 80
#       }
#       volume_mounts {
#         name       = data.google_secret_manager_secret_version.my_secret.secret
#         mount_path = "/mnt/"
#       }
#     }
#     volumes {
#       name = data.google_secret_manager_secret_version.my_secret.secret
#       secret {
#         secret = data.google_secret_manager_secret_version.my_secret.secret
#         items {
#           version = data.google_secret_manager_secret_version.my_secret.version
#           path    = "shared"
#         }
#       }
#     }
#     vpc_access {
#       network_interfaces {
#         network    = module.network.vpc_id
#         subnetwork = module.network.subnetwork_private_id
#       }
#       egress = "ALL_TRAFFIC"
#     }
#     service_account = google_service_account.sa.email
#   }
#   traffic {
#     type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
#     percent = 100
#   }

#   labels = {
#     "created-by" : "terraform"
#   }

# }

# data "google_iam_policy" "noauth" {
#   binding {
#     role = "roles/run.invoker"
#     members = [
#       "allUsers",
#     ]
#   }
# }

# resource "google_cloud_run_service_iam_policy" "policy" {
#   location    = var.region
#   project     = var.project_id
#   service     = google_cloud_run_v2_service.cloudrun.name
#   policy_data = data.google_iam_policy.noauth.policy_data
# }

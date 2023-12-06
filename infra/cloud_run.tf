resource "google_project_service" "cloudrun_api" {
  project            = var.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = true
}


resource "google_cloud_run_v2_service" "cloudrun" {
  depends_on   = [google_project_service.cloudrun_api]
  name         = var.cloudrun_name
  location     = var.region
  project      = var.project_id
  launch_stage = "BETA"

  template {

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = 4
    }
    containers {
      image = "europe-west3-docker.pkg.dev/dgcp-sandbox-lalit-sharma/my-customnginx/customnginx"

      env {
        name  = "_SERVICE_NAME"
        value = var.cloudrun_name
      }
      env {
        name  = "_PROJECT_ID"
        value = var.project_id
      }
      env {
        name = "MY_SECRET_REF"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret_version.my_secret.secret
            version = data.google_secret_manager_secret_version.my_secret.version
          }
        }
      }
      ports {
        container_port = 80
      }
      volume_mounts {
        name       = data.google_secret_manager_secret_version.my_secret.secret
        mount_path = "/mnt/"
      }
    }
    volumes {
      name = data.google_secret_manager_secret_version.my_secret.secret
      secret {
        secret = data.google_secret_manager_secret_version.my_secret.secret
        items {
          version = data.google_secret_manager_secret_version.my_secret.version
          path    = "shared"
        }
      }
    }
    vpc_access {
      network_interfaces {
        network    = module.network.vpc_id
        subnetwork = module.network.subnetwork_private_id
        #       tags       = ["tag1", "tag2", "tag3"]
      }
      egress = "ALL_TRAFFIC"
    }
    service_account = "cloudbuild@dgcp-sandbox-lalit-sharma.iam.gserviceaccount.com"
  }
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  labels = {
    "created-by" : "terraform"
  }

}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "policy" {
  location    = var.region
  project     = var.project_id
  service     = google_cloud_run_v2_service.cloudrun.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

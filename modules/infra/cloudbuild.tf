resource "google_project_service" "cloudbuild_api" {
  project            = var.project_id
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

# data "google_iam_policy" "p4sa-secretAccessor" {
#   binding {
#     role = "roles/secretmanager.secretAccessor"
#     // Here, 123456789 is the Google Cloud project number for my-project-name.
#     members = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
#   }
# }

# resource "google_secret_manager_secret_iam_policy" "policy" {
#   secret_id   = "projects/${data.google_project.project.number}/secrets/oauth_token_secret"
#   policy_data = data.google_iam_policy.p4sa-secretAccessor.policy_data
# }

# resource "google_cloudbuildv2_connection" "my-connection" {
#   location = var.region
#   name     = "git-connection"

#   github_config {
#     app_installation_id = 123123
#     authorizer_credential {
#       oauth_token_secret_version = "projects/${data.google_project.project.number}/secrets/oauth_token_secret/versions/1"
#     }
#   }
# }

# resource "google_cloudbuildv2_repository" "my-repository" {
#   name              = "my-cloudbuild-repo"
#   parent_connection = google_cloudbuildv2_connection.my-connection.id
#   remote_uri        = "https://github.com/lsharma-git/custom-image.git"
# }

###############################################

resource "google_cloudbuild_trigger" "image_trigger" {
  depends_on  = [google_project_service.cloudbuild_api]
  description = "dbg-image-build-trigger"
  disabled    = false
  filename    = "cloudbuild.yaml"
  location    = "europe-west3"
  name        = "dbg-image-build-trigger"
  project     = var.project_id
  substitutions = {
    "_IMAGE_NAME" = "customnginx"
    "_REPO_NAME"  = "my-customnginx"
    "_PROJECT_ID" = var.project_id
  }

  repository_event_config {
    repository = "projects/dgcp-sandbox-lalit-sharma/locations/europe-west3/connections/learner-git/repositories/lsharma-git-nginx-custom-image"

    push {
      branch       = "^main$"
      invert_regex = false
    }
  }

  timeouts {}
}

################################

# resource "google_cloudbuild_trigger" "infra_trigger" {
#   depends_on      = [google_project_service.cloudbuild_api]
#   description     = "dbg-infra-trigger"
#   disabled        = false
#   location        = "europe-west3"
#   name            = "dbg-infra-plan-trigger"
#   project         = var.project_id
#   service_account = "projects/-/serviceAccounts/pipeline@dgcp-sandbox-lalit-sharma.iam.gserviceaccount.com"
#   substitutions = {
#     "_ENV"        = "dev"
#     "_PROJECT_ID" = var.project_id
#     "_TF_VERSION" = "1.2.3"
#   }

#   build {
#     step {
#       args = [
#         "-c",
#         "terraform init -backend=true -backend-config='bucket=terraform_private_tfstate_files'",
#       ]
#       dir        = "$_ENV"
#       entrypoint = "sh"
#       id         = "tf init"
#       name       = "hashicorp/terraform:$_TF_VERSION"
#     }
#     step {
#       args = [
#         "-c",
#         "terraform workspace select $_ENV-mp || terraform workspace new $_ENV-mp",
#       ]
#       dir        = "$_ENV"
#       entrypoint = "sh"
#       id         = "tf workspace"
#       name       = "hashicorp/terraform:$_TF_VERSION"
#     }
#     step {
#       args = [
#         "-c",
#         "terraform plan -var 'project_id=$_PROJECT_ID'",
#       ]
#       dir        = "$_ENV"
#       entrypoint = "sh"
#       id         = "tf plan"
#       name       = "hashicorp/terraform:$_TF_VERSION"
#     }
#   }

#   repository_event_config {
#     repository = "projects/dgcp-sandbox-lalit-sharma/locations/europe-west3/connections/learner-git/repositories/lsharma-git-mp-gcp"

#     push {
#       branch       = "^main$"
#       invert_regex = false
#     }
#   }

#   timeouts {}
# }

######################################

resource "google_cloudbuild_trigger" "test_trigger" {
  depends_on  = [google_project_service.cloudbuild_api]
  name        = "test-mp-trigger"
  description = "Test trigger"
  project     = var.project_id
  location    = "europe-west3"

  pubsub_config {
    topic = google_pubsub_topic.cloudbuild_topic.id
  }

  build {
    step {
      id         = "tf init"
      entrypoint = "sh"
      name       = "hashicorp/terraform:$_TF_VERSION"
      args = [
        "-c",
        <<-EOT
          git clone https://github.com/lsharma-git/mp-gcp.git
          cd mp-gcp/$_ENV 
          terraform init -backend=true -backend-config='bucket=terraform_private_tfstate_files'
        EOT
      ]
    }
    step {
      args = [
        "-c",
        <<-EOT
          cd mp-gcp/$_ENV
          terraform workspace select $_ENV-mp || terraform workspace new $_ENV-mp
        EOT
      ]
      entrypoint = "sh"
      id         = "tf workspace"
      name       = "hashicorp/terraform:$_TF_VERSION"
    }
    step {
      args = [
        "-c",
        <<-EOT
          cd mp-gcp/$_ENV
          terraform plan -var 'project_id=$_PROJECT_ID'
        EOT
      ]
      entrypoint = "sh"
      id         = "tf plan"
      name       = "hashicorp/terraform:$_TF_VERSION"
    }

    timeout = "3600s"

  }

  substitutions = {
    _TF_VERSION = "1.3.2"
    _PROJECT_ID = var.project_id
    _ENV        = var.environment
  }

  #  service_account = google_service_account.sa.member

}

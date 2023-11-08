resource "google_project_service" "artifactregistry_api" {
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = true
}

resource "google_artifact_registry_repository" "my-repo" {
  depends_on    = [google_project_service.artifactregistry_api]
  location      = var.region
  project       = var.project_id
  repository_id = "my-artifact-registry"
  description   = "My GCP repository"
  format        = "DOCKER"
  labels = {
    "type" = "project1",
    "env"  = "test",
    "created-by" : "terraform"
  }
}

# resource "google_kms_crypto_key_iam_member" "crypto_key" {
#   crypto_key_id = "kms-key"
#   role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
#   member        = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com"
# }

data "google_project" "project" {}


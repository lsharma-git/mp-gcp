module "sa" {
  source             = "../../modules/iam/service_account"
  service_account_id = "cloudrun-sa-test"
  display_name       = "Service Account created by terraform"
  sa_role            = toset(var.sa_role)
  project_id         = var.project_id
}

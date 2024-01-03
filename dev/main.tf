module "infra" {
  source      = "../modules/infra"
  project_id  = var.project_id
  environment = var.environment
}

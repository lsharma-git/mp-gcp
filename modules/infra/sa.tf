resource "google_service_account" "sa" {
  account_id   = "service-account-id-${var.environment}"
  display_name = var.sa_display_name
  project      = var.project_id
}

resource "google_service_account_key" "sa_key" {
  service_account_id = google_service_account.sa.name
}

# resource "google_service_account_iam_member" "iam_member" {
#   for_each           = length(var.sa_role) > 0 ? var.sa_role : []
#   service_account_id = google_service_account.sa.name
#   role               = each.key
#   member             = google_service_account.sa.member
# }
resource "google_project_iam_member" "project_iam_member" {
  for_each = length(var.sa_role) > 0 ? toset(var.sa_role) : []
  project  = var.project_id
  role     = each.key
  member   = google_service_account.sa.member
}

data "google_secret_manager_secret_version" "my_secret" {
  secret  = "secretproject"
  version = "latest"
}

output "sa_member" {
  value = google_service_account.sa.member
}
# output "secret" {
#   value = sensitive(local.secret)
# }
output "private_key_sa" {
  value = google_service_account_key.sa_key.private_key
}
output "id" {
  value = google_service_account.sa.id
}
output "member" {
  value = google_service_account.sa.member
}
output "output_all" {
  value = google_service_account.sa
}
output "email" {
  value = google_service_account.sa.email
}

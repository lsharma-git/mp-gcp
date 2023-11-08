output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "subnetwork_private_id" {
  value = google_compute_subnetwork.private.id
}

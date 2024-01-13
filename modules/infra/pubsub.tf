resource "google_pubsub_topic" "cloudbuild_topic" {
  name    = "test-cloudbuild-deployment-topic"
  project = var.project_id
  labels  = { "origin" = "terraform" }
}

resource "google_pubsub_subscription" "cloudbuild_subscription" {
  name                 = "test-cloudbuild-subscription"
  topic                = google_pubsub_topic.cloudbuild_topic.name
  ack_deadline_seconds = 10
}

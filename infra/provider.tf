terraform {
  required_version = ">= 0.12"

  # We need the google-beta provider to be able to work with secrets
  required_providers {
    google-beta = "~> 5.0"
    google      = "~> 5.0"
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
    local = {
      version = "~> 2.1"
    }
  }
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
provider "google" {
  project = var.project_id
  region  = var.region
}

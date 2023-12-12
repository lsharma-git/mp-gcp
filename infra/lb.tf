resource "google_project_service" "compute_api" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "usage_api" {
  project            = var.project_id
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "resource_api" {
  project            = var.project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_global_address" "lb_ip" {
  name = "${var.service_name}-lb-address"
}

resource "google_compute_ssl_policy" "ssl_policy" {
  project         = var.project_id
  name            = "ssl-policy"
  profile         = "RESTRICTED"
  min_tls_version = "TLS_1_2"
  depends_on      = [google_project_service.compute_api]
}

resource "google_compute_managed_ssl_certificate" "ssl_certificate" {
  project = var.project_id
  name    = "cert-${var.loadbalancer_name}-${var.service_name}-${var.environment}"

  managed {
    domains = var.managed_ssl_certificate_domains
  }

  lifecycle {
    create_before_destroy = false
  }

  depends_on = [google_project_service.compute_api]
}

resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  name                  = "${var.service_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_v2_service.cloudrun.name
  }
}

resource "google_compute_backend_service" "default" {
  name = "${var.service_name}-backend"

  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.cloudrun_neg.id
  }
}

resource "google_compute_url_map" "load_balancer" {
  name            = "${var.service_name}-load-balancer"
  project         = var.project_id
  description     = "Map traffic to Cloud Run services"
  default_service = google_compute_backend_service.default.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "mysite"
  }

  #   # host_rule {
  #   #   hosts        = ["myothersite.com"]
  #   #   path_matcher = "otherpaths"
  #   # }

  path_matcher {
    name            = "mysite"
    default_service = google_compute_backend_service.default.id

    path_rule {
      paths   = ["/"]
      service = google_compute_backend_service.default.id
    }
  }

  #   # path_matcher {
  #   #   name            = "otherpaths"
  #   #   default_service = google_cloudrun_service.service2.id

  #   #   path_rule {
  #   #     paths   = ["/service2"]
  #   #     service = google_cloudrun_service.service2.id
  #   #   }
}

# resource "google_compute_url_map" "url_map" {
#   name = "${var.service_name}-urlmap"
#   default_url_redirect {
#     https_redirect         = true
#     redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
#     strip_query            = false
#   }

#   default_service = google_compute_backend_service.default.id
# }

resource "google_compute_health_check" "http_health_check" {
  name               = "health-check"
  timeout_sec        = 1
  check_interval_sec = 1
  http_health_check {
    port = 8080
  }
}

resource "google_compute_target_http_proxy" "http_redirect" {
  project = var.project_id
  name    = "${var.service_name}-http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_target_https_proxy" "https_redirect" {
  project          = var.project_id
  name             = "${var.service_name}-https-proxy"
  ssl_policy       = google_compute_ssl_policy.ssl_policy.self_link
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_certificate.self_link]
}

resource "google_compute_global_forwarding_rule" "https_redirect" {
  name       = "${var.service_name}-lb-http-forwarding-rule"
  target     = google_compute_target_http_proxy.https_redirect.id
  ip_address = google_compute_global_address.lb_ip.address
  port_range = "80"
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  project    = var.project_id
  name       = "${var.service_name}-lb-https-forwarding-rule"
  ip_address = google_compute_global_address.lb_ip.address
  target     = google_compute_target_https_proxy.https_proxy.self_link
  port_range = "443"
}

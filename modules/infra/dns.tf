# resource "google_dns_record_set" "load_balancer_a" {
#   name    = "example.com"
#   type    = "A"
#   ttl     = 300
#   managed = true

#   rrdatas = [google_compute_forwarding_rule.load_balancer.address]
# }

variable "name" {}
variable "ip_cidr_range" {}
variable "list_of_ports_web_fw" {
  type    = list(string)
  default = []
}
variable "source_ip_ranges_webfw" {
  type    = list(string)
  default = []
}
variable "source_ip_ranges_sshfw" {
  type    = list(string)
  default = []
}

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.40.0"
    }
  }
}

resource "digitalocean_record" "dns" {
  domain = var.tld
  name   = var.subdomain
  type   = "A"
  value  = var.ip_address
  ttl    = var.ttl
}

output "dns_record" {
  value = "${digitalocean_record.dns.fqdn}"
}

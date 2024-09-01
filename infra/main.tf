terraform {
  required_version = ">= 1.8.1"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.40.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# DigitalOcean Droplet to run the site
module "hpkio_server" {
  do_token    = var.do_token
  source      = "./modules/droplet"
  server_name = coalesce(var.server_name, "hpkio-${terraform.workspace}")
  region      = var.region
  size        = var.size
  image       = var.image
  ssh_keys    = [var.ssh_fingerprint]
  monitoring  = var.monitoring
  backups     = var.backups
  tags        = var.tags
}

# DNS A Record definition for named access to the Droplet
module "hpkio_dns" {
  source      ="./modules/do_dns"
  do_token    = var.do_token
  tld         = var.tld
  subdomain   = coalesce(var.subdomain, "${terraform.workspace}.this")
  ip_address  = module.hpkio_server.droplet_ip
  ttl         = 300
}

output "server_ip" {
  value = module.hpkio_server.droplet_ip
}

output "dns_record" {
  # value = "${digitalocean_record.hpkio_dns.fqdn}"
  value = module.hpkio_dns.dns_record
}
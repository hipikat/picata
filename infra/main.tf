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
resource "digitalocean_droplet" "hpk_server" {
  name       = terraform.workspace == "prod" ? var.tld : "hpk-${terraform.workspace}"
  region     = var.region
  size       = var.droplet_size
  image      = var.image
  ssh_keys   = [var.ssh_fingerprint]
  monitoring = var.monitoring
  backups    = var.backups
  tags       = var.tags
  user_data = templatefile("${path.module}/${var.cloud_init_config}", {
    development       = var.development
    production        = var.production
    timezone          = var.timezone
    fqdn              = terraform.workspace == "prod" ? var.tld : format("%s.for.%s", terraform.workspace, var.tld)
    node_version      = var.node_version
    admin_django_user = var.admin_django_user
    admin_email       = format("%s@%s", var.admin_email_name, var.tld)
    admin_password    = var.admin_password
    db_name           = var.db_name
    db_user           = var.db_user
    db_password       = var.db_password
    gunicorn_config   = var.gunicorn_config
    internal_ips      = var.internal_ips
    gmail_password    = var.gmail_password
    secret_key        = var.secret_key
    snapshot_password = var.snapshot_password
    uv_no_sync        = tostring(var.uv_no_sync)
  })
}

output "droplet_id" {
  value = digitalocean_droplet.hpk_server.id
}

output "server_ip" {
  value = digitalocean_droplet.hpk_server.ipv4_address
}

# DigitalOcean DNS A Record
resource "digitalocean_record" "hpk_dns" {
  domain = var.tld
  name   = terraform.workspace == "prod" ? "@" : "${terraform.workspace}.for"
  type   = "A"
  value  = digitalocean_droplet.hpk_server.ipv4_address
  ttl    = 300
}

output "dns_record" {
  value = digitalocean_record.hpk_dns.fqdn
}

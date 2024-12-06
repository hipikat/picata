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
module "hpk_server" {
  do_token    = var.do_token
  source      = "./modules/droplet"
  server_name = coalesce(var.server_name, "hpk-${terraform.workspace}")
  region      = var.region
  size        = var.droplet_size
  image       = var.image
  ssh_keys    = [var.ssh_fingerprint]
  monitoring  = var.monitoring
  backups     = var.backups
  tags        = var.tags
  user_data = templatefile("${path.module}/${var.cloud_init_config}", {
    timezone          = var.timezone
    fqdn              = format("%s.%s", coalesce(var.subdomain, "${terraform.workspace}.for"), var.tld)
    node_version      = var.node_version
    admin_django_user = var.admin_django_user
    admin_email       = format("%s@%s", var.admin_email_name, var.tld)
    admin_password    = var.admin_password
    db_name           = var.db_name
    db_user           = var.db_user
    db_password       = var.db_password
    gunicorn_config   = var.gunicorn_config
    internal_ips      = var.internal_ips
    certbot_args      = var.certbot_args
    gmail_password    = var.gmail_password
  })
}

# DNS A Record definition for named access to the Droplet
module "hpk_dns" {
  source     = "./modules/do_dns"
  do_token   = var.do_token
  tld        = var.tld
  subdomain  = coalesce(var.subdomain, "${terraform.workspace}.for")
  ip_address = module.hpk_server.droplet_ip
  ttl        = 300
}

output "dns_record" {
  value = module.hpk_dns.dns_record
}

output "droplet_id" {
  value = module.hpk_server.droplet_id
}

output "server_ip" {
  value = module.hpk_server.droplet_ip
}

terraform {
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

resource "digitalocean_droplet" "droplet" {
  name       = var.server_name
  region     = var.region
  size       = var.size
  image      = var.image
  ssh_keys   = var.ssh_keys
  monitoring = var.monitoring
  backups    = var.backups
  tags       = var.tags
  user_data  = file("${path.module}/../../../scripts/cloud-init-dev.yml")
}
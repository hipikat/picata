terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.40.0"
    }
  }
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
  user_data  = var.user_data
}

output "droplet_id" {
  value = digitalocean_droplet.droplet.id
}
output "droplet_ip" {
  value = digitalocean_droplet.droplet.ipv4_address
}

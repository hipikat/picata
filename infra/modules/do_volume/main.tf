terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.40.0"
    }
  }
}

resource "digitalocean_volume" "volume" {
  name                    = var.volume_name
  region                  = var.region
  size                    = var.volume_size
  initial_filesystem_type = var.filesystem_type
  description             = var.volume_description
}

output "volume_id" {
  value = digitalocean_volume.volume.id
}
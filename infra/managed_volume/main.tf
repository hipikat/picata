# Configuration for creating a persistent volume, named for the workspace

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

# Persistent Volume
resource "digitalocean_volume" "managed_volume" {
  name                    = terraform.workspace
  region                  = var.region
  size                    = var.volume_size
  initial_filesystem_type = var.volume_filesystem_type
  description             = var.volume_description
}

output "managed_volume_id" {
  value = digitalocean_volume.managed_volume.id
}

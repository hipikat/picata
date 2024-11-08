# Configuration for creating a persistent volumes, named for their workspace

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

module "managed_volume" {
  source             = "../modules/do_volume"
  volume_name        = "${terraform.workspace}"
  region             = var.region
  volume_size        = var.volume_size
  filesystem_type    = var.volume_filesystem_type
  volume_description = var.volume_description
}

output "managed_volume_id" {
  value = module.managed_volume.volume_id
}
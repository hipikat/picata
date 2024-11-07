# Configuration for creating a persistent volume for VSCode data, so extensions
# don't need to be reinstalled for each new instance of a development server.

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

module "vscode_data_volume" {
  source           = "../modules/do_volume"
  volume_name      = "vscode-data"
  volume_size      = 5
  filesystem_type  = var.volume_filesystem_type
  region           = var.region
  volume_description = "Persistent storage for VSCode data"
}

output "vscode_volume_id" {
  value = module.vscode_data_volume.volume_id
}
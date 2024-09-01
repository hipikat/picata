terraform {
  required_version = ">= 1.8.1"
}

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
terraform {
  required_version = ">= 1.8.1"
}

module "hpkio_server" {
  source     = "./modules/droplet"
  do_token   = var.do_token
  name       = var.name
  region     = var.region
  size       = var.size
  image      = var.image
  ssh_keys   = [var.ssh_fingerprint]
  monitoring = var.monitoring
  backups    = var.backups
  tags       = var.tags
}
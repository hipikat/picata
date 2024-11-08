# Authentication
variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

# DNS record management
variable "tld" {
  description = "Top-level domain"
  type        = string
}

variable "subdomain" {
  description = "The subdomain name for the DNS record"
  type        = string
  default = null
}

# Server infrastructure
variable "ssh_fingerprint" {
  description = "SSH key fingerprint"
  type        = string
}

variable "server_name" {
  description = "Name of the Droplet"
  type        = string
  default = null
}

variable "region" {
  description = "Region for the Droplet"
  type        = string
}

variable "droplet_size" {
  description = "Size of the Droplet"
  type        = string
}

variable "image" {
  description = "Droplet image"
  type        = string
}

variable "monitoring" {
  description = "Enable monitoring"
  type        = bool
  default     = false
}

variable "backups" {
  description = "Enable backups"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for the Droplet"
  type        = list(string)
  default     = []
}

variable "cloud_init_config" {
  description = "Path to cloud-init configuration file"
  type        = string
  default = "../scripts/cloud-init.yml"
}


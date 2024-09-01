variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name of the droplet"
  type        = string
}

variable "region" {
  description = "Region for the droplet"
  type        = string
}

variable "size" {
  description = "Size of the droplet"
  type        = string
}

variable "image" {
  description = "Droplet image"
  type        = string
}

variable "ssh_keys" {
  description = "SSH keys"
  type        = list(string)
  default     = []
}

variable "monitoring" {
  description = "Enable monitoring"
  type        = bool
}

variable "backups" {
  description = "Enable backups"
  type        = bool
}

variable "tags" {
  description = "Tags for the droplet"
  type        = list(string)
  default     = []
}

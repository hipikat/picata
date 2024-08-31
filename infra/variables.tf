variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "ssh_fingerprint" {
  description = "SSH key fingerprint"
  type        = string
}

variable "name" {
  description = "Name of the Droplet"
  type        = string
}

variable "region" {
  description = "Region for the Droplet"
  type        = string
  default     = "syd1"
}

variable "size" {
  description = "Size of the Droplet"
  type        = string
  default     = "s-1vcpu-1gb-amd"
}

variable "image" {
  description = "Droplet image"
  type        = string
  default     = "ubuntu-24-04-x64"
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

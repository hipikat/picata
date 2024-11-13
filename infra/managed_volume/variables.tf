variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Region for the Droplet"
  type        = string
}

variable "volume_filesystem_type" {
  description = "Filesystem type for the volume"
  type        = string
  default     = "ext4"
}

variable "volume_size" {
  description = "Size of the volume in GB"
  type        = number
}

variable "volume_description" {
  description = "Description of the volume"
  type        = string
}

# Unused variables defined in ../settings.tfvars and ./secrets.tfvars;
# included to suppress warnings about unused variables from tofu calls

variable "tld" {
  description = "Top-level domain"
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

variable "ssh_fingerprint" {
  description = "SSH key fingerprint"
  type        = string
}

variable "admin_password" {
  description = "Admin user password"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
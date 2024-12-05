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
  default     = null
}

# Server infrastructure
variable "ssh_fingerprint" {
  description = "SSH key fingerprint"
  type        = string
}

variable "server_name" {
  description = "Name of the Droplet"
  type        = string
  default     = null
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
}

variable "gunicorn_config" {
  description = "Name of the Gunicorn configuration file to use"
  type        = string
}

variable "certbot_args" {
  description = "Arguments to pass to certbot when issuing SSL certificates"
  type        = string
  default     = "--staging"
}

variable "node_version" {
  description = "Node.js version to install"
  type        = string
}

variable "admin_django_user" {
  description = "Admin user name for Django"
  type        = string
}

variable "admin_password" {
  description = "Admin user password for the application backend"
  type        = string
  sensitive   = true
}

variable "admin_email_name" {
  description = "Username part for the admin email address"
  type        = string
}

variable "gmail_password" {
  description = "Password for the Gmail account used to send emails"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "internal_ips" {
  description = "Space-separated list of internal IP addresses"
  type        = string
  default     = ""
}

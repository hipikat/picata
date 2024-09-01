
variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "tld" {
  description = "The domain to manage DNS records for"
  type        = string
}

variable "subdomain" {
  description = "The subdomain name for the DNS record"
  type        = string
}

variable "ip_address" {
  description = "The IP address to point the DNS record to"
  type        = string
}

variable "ttl" {
  description = "TTL for the DNS record"
  type        = number
  default     = 300
}

variable "volume_name" {
  description = "The name of the volume"
  type        = string
}

variable "volume_size" {
  description = "Size of the volume in GiB"
  type        = number
}

variable "filesystem_type" {
  description = "Filesystem type for the volume"
  type        = string
  default     = "ext4"
}

variable "region" {
  description = "Region where the volume should be created"
  type        = string
}

variable "volume_description" {
  description = "Description of the volume"
  type        = string
}

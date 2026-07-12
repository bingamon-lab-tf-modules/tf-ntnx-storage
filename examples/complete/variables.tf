##################################################
# Provider Variables
##################################################

variable "nutanix_username" {
  description = "Nutanix Prism Central username"
  type        = string
}

variable "nutanix_password" {
  description = "Nutanix Prism Central password"
  type        = string
  sensitive   = true
}

variable "nutanix_endpoint" {
  description = "Nutanix Prism Central endpoint"
  type        = string
}

variable "nutanix_insecure" {
  description = "Allow insecure TLS connections"
  type        = bool
  default     = false
}

##################################################
# Storage Variables
##################################################

variable "cluster_ext_id" {
  description = "Nutanix cluster external ID for storage container and volume group placement"
  type        = string
}

variable "storage_container_ext_id" {
  description = "Existing storage container external ID used as the disk data source for volume group disks"
  type        = string
}

variable "volume_group_ext_id" {
  description = "Existing volume group external ID to attach volume group disks to"
  type        = string
}

variable "vm_ext_id" {
  description = "Existing VM external ID to attach volume groups to"
  type        = string
}

##################################################
# Storage Container Outputs
##################################################

output "storage_containers" {
  description = "Map of created storage containers with their details."
  value = {
    for k, v in nutanix_storage_containers_v2.container : k => {
      ext_id                         = v.ext_id
      name                           = v.name
      cluster_ext_id                 = v.cluster_ext_id
      replication_factor             = v.replication_factor
      erasure_code                   = v.erasure_code
      is_compression_enabled         = v.is_compression_enabled
      is_software_encryption_enabled = v.is_software_encryption_enabled
    }
  }
}

output "storage_container_ids" {
  description = "Map of storage container keys to their external IDs."
  value       = { for k, v in nutanix_storage_containers_v2.container : k => v.ext_id }
}

##################################################
# Volume Group Outputs
##################################################

output "volume_groups" {
  description = "Map of created volume groups with their details."
  value = {
    for k, v in nutanix_volume_group_v2.volume_group : k => {
      ext_id            = v.ext_id
      name              = v.name
      cluster_reference = v.cluster_reference
      sharing_status    = v.sharing_status
      usage_type        = v.usage_type
      target_name       = v.target_name
    }
  }
}

output "volume_group_ids" {
  description = "Map of volume group keys to their external IDs."
  value       = { for k, v in nutanix_volume_group_v2.volume_group : k => v.ext_id }
}

##################################################
# Volume Group Disk Outputs
##################################################

output "volume_group_disks" {
  description = "Map of created volume group disks with their details."
  value = {
    for k, v in nutanix_volume_group_disk_v2.disk : k => {
      ext_id              = v.ext_id
      volume_group_ext_id = v.volume_group_ext_id
      index               = v.index
      disk_size_bytes     = v.disk_size_bytes
    }
  }
}

output "volume_group_disk_ids" {
  description = "Map of volume group disk keys to their external IDs."
  value       = { for k, v in nutanix_volume_group_disk_v2.disk : k => v.ext_id }
}

##################################################
# Summary
##################################################

output "storage_summary" {
  description = "Summary of storage resources managed by this module."
  value = {
    total_storage_containers = length(var.storage_containers)
    total_volume_groups      = length(var.volume_groups)
    total_volume_group_disks = length(var.volume_group_disks)
    compressed_containers    = length(local.compressed_containers)
    ec_containers            = length(local.ec_containers)
    encrypted_containers     = length(local.encrypted_containers)
    shared_volume_groups     = length(local.shared_volume_groups)
  }
}

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
      description         = v.description
    }
  }
}

output "volume_group_disk_ids" {
  description = "Map of volume group disk keys to their external IDs."
  value       = { for k, v in nutanix_volume_group_disk_v2.disk : k => v.ext_id }
}

##################################################
# Volume Group VM Attachment Outputs
##################################################

output "volume_group_vm_attachments" {
  description = "Map of volume group VM attachments with their details."
  value = {
    for k, v in nutanix_volume_group_vm_v2.vm_attachment : k => {
      volume_group_ext_id = v.volume_group_ext_id
      vm_ext_id           = v.vm_ext_id
      index               = v.index
    }
  }
}

##################################################
# Storage Policy Outputs
##################################################

output "storage_policies" {
  description = "Map of created storage policies with their details."
  value = {
    for k, v in nutanix_storage_policy_v2.storage_policy : k => {
      ext_id           = v.ext_id
      name             = v.name
      policy_type      = v.policy_type
      category_ext_ids = v.category_ext_ids
    }
  }
}

output "storage_policy_ids" {
  description = "Map of storage policy keys to their external IDs."
  value       = { for k, v in nutanix_storage_policy_v2.storage_policy : k => v.ext_id }
}

##################################################
# Volume Group iSCSI Client Outputs
##################################################

output "volume_group_iscsi_clients" {
  description = "Map of volume group iSCSI clients with their details (no secrets)."
  value = {
    for k, v in nutanix_volume_group_iscsi_client_v2.iscsi_client : k => {
      ext_id                  = v.ext_id
      vg_ext_id               = v.vg_ext_id
      iscsi_initiator_name    = v.iscsi_initiator_name
      enabled_authentications = v.enabled_authentications
      num_virtual_targets     = v.num_virtual_targets
    }
  }
}

output "volume_group_iscsi_client_ids" {
  description = "Map of volume group iSCSI client keys to their external IDs."
  value       = { for k, v in nutanix_volume_group_iscsi_client_v2.iscsi_client : k => v.ext_id }
}

##################################################
# Volume Group Category Association Outputs
##################################################

output "volume_group_category_associations" {
  description = "Map of volume group category associations with their resolved VG ext_id and categories."
  value = {
    for k, v in nutanix_associate_category_to_volume_group_v2.category_association : k => {
      vg_ext_id  = v.ext_id
      categories = v.categories
    }
  }
}

##################################################
# Summary
##################################################

output "storage_summary" {
  description = "Summary of storage resources managed by this module."
  value = {
    total_storage_containers                 = length(var.storage_containers)
    total_volume_groups                      = length(var.volume_groups)
    total_volume_group_disks                 = length(var.volume_group_disks)
    total_storage_policies                   = length(var.storage_policies)
    total_volume_group_iscsi_clients         = length(var.volume_group_iscsi_clients)
    total_volume_group_category_associations = length(var.volume_group_category_associations)
    compressed_containers                    = length(local.compressed_containers)
    ec_containers                            = length(local.ec_containers)
    encrypted_containers                     = length(local.encrypted_containers)
    shared_volume_groups                     = length(local.shared_volume_groups)
    compression_policies                     = length(local.compression_policies)
    encrypted_policies                       = length(local.encrypted_policies)
    throttled_policies                       = length(local.throttled_policies)
    chap_iscsi_clients                       = length(local.chap_iscsi_clients)
  }
}

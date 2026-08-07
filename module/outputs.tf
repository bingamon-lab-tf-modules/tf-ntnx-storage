##################################################
# Storage Container Outputs
##################################################

# The provider populates the storage container's identifier as `container_ext_id`, NOT
# `ext_id`, on the RESOURCE. Both attributes exist in the schema, but the clustermgmt v4
# StorageContainer model carries `extId` and `containerExtId` as separate omitempty fields
# and the API leaves `extId` null — so `v.ext_id` lands in state as an empty STRING.
#
# The two data sources hide this by aliasing containerExtId onto both attributes; the
# resource does not. `try()` is no help because "" is not an error — use coalesce(), which
# skips null AND empty string. `.id` is the last resort and always holds the real UUID.
#
# Symptom this fixes: storage_container_ids came back as { "<key>" = "" }, and those empty
# strings were being handed to tf-ntnx-vm as a VM disk's storage_container.ext_id.
output "storage_containers" {
  description = "Map of created storage containers with their details."
  value = {
    for k, v in nutanix_storage_containers_v2.container : k => {
      ext_id                         = coalesce(v.container_ext_id, v.ext_id, v.id)
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
  # See the note on `storage_containers` — the resource populates `container_ext_id`.
  value = { for k, v in nutanix_storage_containers_v2.container : k => coalesce(v.container_ext_id, v.ext_id, v.id) }
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

# DEFENSIVE, not observed. `nutanix_volume_group_iscsi_client_v2` is suspected of the same
# defect as the storage container above — its Read path appears not to populate `ext_id`.
# No iSCSI clients are deployed anywhere in the estate yet, so this has never been seen in
# practice. coalesce() costs nothing and removes the trap before the first one is created.
output "volume_group_iscsi_clients" {
  description = "Map of volume group iSCSI clients with their details (no secrets)."
  value = {
    for k, v in nutanix_volume_group_iscsi_client_v2.iscsi_client : k => {
      ext_id                  = coalesce(v.ext_id, v.id)
      vg_ext_id               = v.vg_ext_id
      iscsi_initiator_name    = v.iscsi_initiator_name
      enabled_authentications = v.enabled_authentications
      num_virtual_targets     = v.num_virtual_targets
    }
  }
}

output "volume_group_iscsi_client_ids" {
  description = "Map of volume group iSCSI client keys to their external IDs."
  # Defensive — see the note on `volume_group_iscsi_clients`.
  value = { for k, v in nutanix_volume_group_iscsi_client_v2.iscsi_client : k => coalesce(v.ext_id, v.id) }
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
  value       = local.out_storage_summary
}

##################################################
# Aggregate output (spec §7.6 contract)
##################################################

output "outputs" {
  description = "Aggregate of all module outputs (spec §7.6 contract, consumed by the landing zone as module.<x>.outputs)."
  value = {
    storage_containers = {
      for k, v in nutanix_storage_containers_v2.container : k => {
        ext_id                         = coalesce(v.container_ext_id, v.ext_id, v.id)
        name                           = v.name
        cluster_ext_id                 = v.cluster_ext_id
        replication_factor             = v.replication_factor
        erasure_code                   = v.erasure_code
        is_compression_enabled         = v.is_compression_enabled
        is_software_encryption_enabled = v.is_software_encryption_enabled
      }
    }
    storage_container_ids = { for k, v in nutanix_storage_containers_v2.container : k => coalesce(v.container_ext_id, v.ext_id, v.id) }
    volume_groups = {
      for k, v in nutanix_volume_group_v2.volume_group : k => {
        ext_id            = v.ext_id
        name              = v.name
        cluster_reference = v.cluster_reference
        sharing_status    = v.sharing_status
        usage_type        = v.usage_type
        target_name       = v.target_name
      }
    }
    volume_group_ids = { for k, v in nutanix_volume_group_v2.volume_group : k => v.ext_id }
    volume_group_disks = {
      for k, v in nutanix_volume_group_disk_v2.disk : k => {
        ext_id              = v.ext_id
        volume_group_ext_id = v.volume_group_ext_id
        index               = v.index
        disk_size_bytes     = v.disk_size_bytes
        description         = v.description
      }
    }
    volume_group_disk_ids = { for k, v in nutanix_volume_group_disk_v2.disk : k => v.ext_id }
    volume_group_vm_attachments = {
      for k, v in nutanix_volume_group_vm_v2.vm_attachment : k => {
        volume_group_ext_id = v.volume_group_ext_id
        vm_ext_id           = v.vm_ext_id
        index               = v.index
      }
    }
    storage_policies = {
      for k, v in nutanix_storage_policy_v2.storage_policy : k => {
        ext_id           = v.ext_id
        name             = v.name
        policy_type      = v.policy_type
        category_ext_ids = v.category_ext_ids
      }
    }
    storage_policy_ids = { for k, v in nutanix_storage_policy_v2.storage_policy : k => v.ext_id }
    volume_group_iscsi_clients = {
      for k, v in nutanix_volume_group_iscsi_client_v2.iscsi_client : k => {
        ext_id                  = coalesce(v.ext_id, v.id)
        vg_ext_id               = v.vg_ext_id
        iscsi_initiator_name    = v.iscsi_initiator_name
        enabled_authentications = v.enabled_authentications
        num_virtual_targets     = v.num_virtual_targets
      }
    }
    volume_group_iscsi_client_ids = { for k, v in nutanix_volume_group_iscsi_client_v2.iscsi_client : k => coalesce(v.ext_id, v.id) }
    volume_group_category_associations = {
      for k, v in nutanix_associate_category_to_volume_group_v2.category_association : k => {
        vg_ext_id  = v.ext_id
        categories = v.categories
      }
    }
    storage_summary = local.out_storage_summary
  }
}

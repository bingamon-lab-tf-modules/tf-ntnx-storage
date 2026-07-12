##################################################
# Storage Containers
##################################################

resource "nutanix_storage_containers_v2" "container" {
  for_each = var.storage_containers

  name                                     = each.value.name
  cluster_ext_id                           = each.value.cluster_ext_id
  logical_advertised_capacity_bytes        = each.value.logical_advertised_capacity_bytes
  logical_explicit_reserved_capacity_bytes = each.value.logical_explicit_reserved_capacity_bytes
  replication_factor                       = each.value.replication_factor
  erasure_code                             = each.value.erasure_code
  is_inline_ec_enabled                     = each.value.is_inline_ec_enabled
  has_higher_ec_fault_domain_preference    = each.value.has_higher_ec_fault_domain_preference
  erasure_code_delay_secs                  = each.value.erasure_code_delay_secs
  cache_deduplication                      = each.value.cache_deduplication
  on_disk_dedup                            = each.value.on_disk_dedup
  is_compression_enabled                   = each.value.is_compression_enabled
  compression_delay_secs                   = each.value.compression_delay_secs
  is_internal                              = each.value.is_internal
  is_software_encryption_enabled           = each.value.is_software_encryption_enabled
  affinity_host_ext_id                     = each.value.affinity_host_ext_id
  owner_ext_id                             = each.value.owner_ext_id

  dynamic "nfs_whitelist_addresses" {
    for_each = each.value.nfs_whitelist_addresses
    content {
      dynamic "ipv4" {
        for_each = nfs_whitelist_addresses.value.ipv4 != null ? [nfs_whitelist_addresses.value.ipv4] : []
        content {
          value         = ipv4.value.value
          prefix_length = ipv4.value.prefix_length
        }
      }
    }
  }
}

##################################################
# Volume Groups
##################################################

resource "nutanix_volume_group_v2" "volume_group" {
  for_each = var.volume_groups

  name                               = each.value.name
  description                        = each.value.description
  cluster_reference                  = each.value.cluster_reference
  should_load_balance_vm_attachments = each.value.should_load_balance_vm_attachments
  sharing_status                     = each.value.sharing_status
  target_name                        = each.value.target_name
  created_by                         = each.value.created_by
  usage_type                         = each.value.usage_type
  is_hidden                          = each.value.is_hidden

  dynamic "iscsi_features" {
    for_each = each.value.iscsi_features != null ? [each.value.iscsi_features] : []
    content {
      enabled_authentications = iscsi_features.value.enabled_authentications
      target_secret           = iscsi_features.value.target_secret
    }
  }

  dynamic "storage_features" {
    for_each = each.value.storage_features != null ? [each.value.storage_features] : []
    content {
      dynamic "flash_mode" {
        for_each = storage_features.value.flash_mode != null ? [storage_features.value.flash_mode] : []
        content {
          is_enabled = flash_mode.value.is_enabled
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      iscsi_features[0].target_secret,
    ]
  }
}

##################################################
# Volume Group Disks
##################################################

resource "nutanix_volume_group_disk_v2" "disk" {
  for_each = var.volume_group_disks

  volume_group_ext_id = each.value.volume_group_ext_id
  index               = each.value.index
  description         = each.value.description
  disk_size_bytes     = each.value.disk_size_bytes

  # When no explicit disk_data_source_reference is given, derive it from
  # disk_data_source (recovery point / VM disk) or storage_container_ext_id.
  disk_data_source_reference {
    ext_id = each.value.disk_data_source_reference != null ? each.value.disk_data_source_reference.ext_id : (
      try(each.value.disk_data_source.recovery_point_ext_id, null) != null ? each.value.disk_data_source.recovery_point_ext_id : (
        try(each.value.disk_data_source.vm_disk_ext_id, null) != null ? each.value.disk_data_source.vm_disk_ext_id : each.value.storage_container_ext_id
      )
    )
    name = each.value.disk_data_source_reference != null ? each.value.disk_data_source_reference.name : null
    entity_type = each.value.disk_data_source_reference != null ? each.value.disk_data_source_reference.entity_type : (
      try(each.value.disk_data_source.recovery_point_ext_id, null) != null ? "DISK_RECOVERY_POINT" : (
        try(each.value.disk_data_source.vm_disk_ext_id, null) != null ? "VM_DISK" : "STORAGE_CONTAINER"
      )
    )
    uris = each.value.disk_data_source_reference != null ? (
      length(each.value.disk_data_source_reference.uris) > 0 ? each.value.disk_data_source_reference.uris : null
    ) : null
  }

  dynamic "disk_storage_features" {
    for_each = each.value.disk_storage_features != null ? [each.value.disk_storage_features] : []
    content {
      dynamic "flash_mode" {
        for_each = disk_storage_features.value.flash_mode != null ? [disk_storage_features.value.flash_mode] : []
        content {
          is_enabled = flash_mode.value.is_enabled
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      disk_data_source_reference,
    ]
  }
}

##################################################
# Volume Group VM Attachments
##################################################

locals {
  # Flatten volume group VM attachments for iteration.
  volume_group_vm_attachments = flatten([
    for vg_key, vg in var.volume_groups : [
      for idx, attachment in vg.vm_attachments : {
        key              = "${vg_key}-vm-${idx}"
        volume_group_key = vg_key
        vm_ext_id        = attachment.vm_ext_id
        index            = attachment.index
      }
    ]
  ])
}

resource "nutanix_volume_group_vm_v2" "vm_attachment" {
  for_each = { for attachment in local.volume_group_vm_attachments : attachment.key => attachment }

  volume_group_ext_id = nutanix_volume_group_v2.volume_group[each.value.volume_group_key].ext_id
  vm_ext_id           = each.value.vm_ext_id
  index               = each.value.index
}

##################################################
# Storage Policies
##################################################

resource "nutanix_storage_policy_v2" "storage_policy" {
  for_each = var.storage_policies

  name             = each.value.name
  category_ext_ids = each.value.category_ext_ids

  dynamic "compression_spec" {
    for_each = each.value.compression_spec != null ? [each.value.compression_spec] : []
    content {
      compression_state = compression_spec.value.compression_state
    }
  }

  dynamic "encryption_spec" {
    for_each = each.value.encryption_spec != null ? [each.value.encryption_spec] : []
    content {
      encryption_state = encryption_spec.value.encryption_state
    }
  }

  dynamic "qos_spec" {
    for_each = each.value.qos_spec != null ? [each.value.qos_spec] : []
    content {
      throttled_iops = qos_spec.value.throttled_iops
    }
  }

  dynamic "fault_tolerance_spec" {
    for_each = each.value.fault_tolerance_spec != null ? [each.value.fault_tolerance_spec] : []
    content {
      replication_factor = fault_tolerance_spec.value.replication_factor
    }
  }
}

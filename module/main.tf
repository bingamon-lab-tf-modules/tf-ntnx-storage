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

  disk_data_source_reference {
    ext_id      = each.value.disk_data_source_reference.ext_id
    name        = each.value.disk_data_source_reference.name
    entity_type = each.value.disk_data_source_reference.entity_type
    uris        = length(each.value.disk_data_source_reference.uris) > 0 ? each.value.disk_data_source_reference.uris : null
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

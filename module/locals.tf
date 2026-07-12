locals {

  ##################################################
  # Storage Containers
  ##################################################

  # Containers with compression enabled
  compressed_containers = {
    for k, v in var.storage_containers : k => v if v.is_compression_enabled
  }

  # Containers with erasure coding enabled
  ec_containers = {
    for k, v in var.storage_containers : k => v if v.erasure_code == "ON"
  }

  # Containers with encryption enabled
  encrypted_containers = {
    for k, v in var.storage_containers : k => v if v.is_software_encryption_enabled
  }

  ##################################################
  # Volume Groups
  ##################################################

  # Shared volume groups
  shared_volume_groups = {
    for k, v in var.volume_groups : k => v if v.sharing_status == "SHARED"
  }

  # Volume groups with iSCSI features
  iscsi_volume_groups = {
    for k, v in var.volume_groups : k => v if v.iscsi_features != null
  }

  ##################################################
  # Storage Policies
  ##################################################

  # Policies that apply a compression effect
  compression_policies = {
    for k, v in var.storage_policies : k => v if v.compression_spec != null
  }

  # Policies that apply an encryption effect
  encrypted_policies = {
    for k, v in var.storage_policies : k => v if v.encryption_spec != null
  }

  # Policies that apply an IOPS-throttling (QoS) effect
  throttled_policies = {
    for k, v in var.storage_policies : k => v if v.qos_spec != null
  }

  ##################################################
  # Volume Group iSCSI Clients / Category Associations
  ##################################################

  # iSCSI clients configured for CHAP authentication
  chap_iscsi_clients = {
    for k, v in var.volume_group_iscsi_clients : k => v if v.enabled_authentications == "CHAP"
  }

  # Resolve a category "name" ("key/value" form) to its ext_id via the gated
  # categories_v2 lookup. Empty when data lookups are disabled.
  category_ext_id_by_name = var.enable_data_lookups ? {
    for c in try(data.nutanix_categories_v2.existing_categories[0].categories, []) :
    "${c.key}/${c.value}" => c.ext_id
  } : {}

  ##################################################
  # Factored output value expressions
  #
  # This larger output value is defined once here and referenced from both its
  # individual `output` block and the aggregate `output "outputs"` (spec §7.6
  # contract). Terraform cannot reference one output from another, so this local
  # is the shared single source of truth. Behaviour is unchanged.
  ##################################################

  # Summary of storage resources (used by output "storage_summary").
  out_storage_summary = {
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

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
}

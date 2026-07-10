# Validate that storage containers have a replication factor set.
check "containers_have_replication_factor" {
  assert {
    condition = alltrue([
      for k, v in var.storage_containers :
      v.replication_factor != null && v.replication_factor >= 1
    ])
    error_message = "Storage containers should have a 'replication_factor' of at least 1."
  }
}

# Validate that volume groups have a cluster reference.
check "volume_groups_have_cluster" {
  assert {
    condition = alltrue([
      for k, v in var.volume_groups :
      v.cluster_reference != null && v.cluster_reference != ""
    ])
    error_message = "Volume groups must have a valid 'cluster_reference'."
  }
}

# Validate that iSCSI volume groups with CHAP have a target secret.
check "iscsi_chap_has_secret" {
  assert {
    condition = alltrue([
      for k, v in var.volume_groups :
      v.iscsi_features == null || v.iscsi_features.enabled_authentications != "CHAP" || v.iscsi_features.target_secret != null
    ])
    error_message = "Volume groups with CHAP authentication should have a 'target_secret' specified."
  }
}

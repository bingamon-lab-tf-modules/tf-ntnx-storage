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

# Validate that each storage policy defines at least one effect and one category.
check "storage_policies_have_effect_and_category" {
  assert {
    condition = alltrue([
      for k, v in var.storage_policies :
      (v.compression_spec != null || v.encryption_spec != null || v.qos_spec != null || v.fault_tolerance_spec != null) &&
      length(v.category_ext_ids) > 0
    ])
    error_message = "Each storage policy must define at least one effect (compression, encryption, qos, or fault_tolerance) and reference at least one category."
  }
}

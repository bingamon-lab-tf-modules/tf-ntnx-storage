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

# Validate that each iSCSI client references a resolvable volume group.
check "iscsi_client_vg_reference_resolvable" {
  assert {
    condition = alltrue([
      for k, v in var.volume_group_iscsi_clients :
      contains(keys(var.volume_groups), v.volume_group) || (v.volume_group != null && v.volume_group != "")
    ])
    error_message = "Each iSCSI client 'volume_group' must reference a var.volume_groups key or a non-empty VG ext_id."
  }
}

# Validate that each iSCSI client identifies an initiator (IQN non-empty or network id).
check "iscsi_client_has_initiator" {
  assert {
    condition = alltrue([
      for k, v in var.volume_group_iscsi_clients :
      (v.iscsi_initiator_name != null && v.iscsi_initiator_name != "") || v.iscsi_initiator_network_id != null
    ])
    error_message = "Each iSCSI client must set a non-empty 'iscsi_initiator_name' (IQN) or an 'iscsi_initiator_network_id'."
  }
}

# Validate that each category association references a resolvable volume group.
check "category_association_vg_reference_resolvable" {
  assert {
    condition = alltrue([
      for k, v in var.volume_group_category_associations :
      contains(keys(var.volume_groups), v.volume_group) || (v.volume_group != null && v.volume_group != "")
    ])
    error_message = "Each category association 'volume_group' must reference a var.volume_groups key or a non-empty VG ext_id."
  }
}

# Validate that every category reference is resolvable to an ext_id: either an
# explicit ext_id, or a name that can be resolved via the gated categories_v2
# lookup (which requires enable_data_lookups = true).
check "category_references_resolvable" {
  assert {
    condition = alltrue([
      for k, v in var.volume_group_category_associations :
      alltrue([
        for c in v.categories :
        (c.ext_id != null && c.ext_id != "") || (c.name != null && c.name != "" && var.enable_data_lookups)
      ])
    ])
    error_message = "Each category reference must supply 'ext_id', or supply 'name' with enable_data_lookups = true so it resolves via the categories_v2 lookup."
  }
}

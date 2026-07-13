##################################################
# Storage Containers
##################################################

variable "storage_containers" {
  description = "A map of storage containers to manage in Nutanix."
  type = map(object({
    name                                     = string
    cluster_ext_id                           = string
    logical_advertised_capacity_bytes        = optional(number, null)
    logical_explicit_reserved_capacity_bytes = optional(number, null)
    replication_factor                       = optional(number, null)
    erasure_code                             = optional(string, "OFF")
    is_inline_ec_enabled                     = optional(bool, false)
    has_higher_ec_fault_domain_preference    = optional(bool, false)
    erasure_code_delay_secs                  = optional(number, null)
    cache_deduplication                      = optional(string, "OFF")
    on_disk_dedup                            = optional(string, "OFF")
    is_compression_enabled                   = optional(bool, true)
    compression_delay_secs                   = optional(number, null)
    is_internal                              = optional(bool, false)
    is_software_encryption_enabled           = optional(bool, false)
    affinity_host_ext_id                     = optional(string, null)
    owner_ext_id                             = optional(string, null)

    nfs_whitelist_addresses = optional(list(object({
      ipv4 = optional(object({
        value         = string
        prefix_length = optional(number, 32)
      }), null)
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.storage_containers :
      contains(["NONE", "OFF", "ON"], v.erasure_code)
    ])
    error_message = "Storage container 'erasure_code' must be one of: NONE, OFF, ON."
  }

  validation {
    condition = alltrue([
      for k, v in var.storage_containers :
      contains(["NONE", "OFF", "ON"], v.cache_deduplication)
    ])
    error_message = "Storage container 'cache_deduplication' must be one of: NONE, OFF, ON."
  }

  validation {
    condition = alltrue([
      for k, v in var.storage_containers :
      contains(["NONE", "OFF", "POST_PROCESS"], v.on_disk_dedup)
    ])
    error_message = "Storage container 'on_disk_dedup' must be one of: NONE, OFF, POST_PROCESS."
  }
}

##################################################
# Volume Groups
##################################################

variable "volume_groups" {
  description = "A map of volume groups to manage in Nutanix."
  type = map(object({
    name                               = string
    description                        = optional(string, null)
    cluster_reference                  = string
    should_load_balance_vm_attachments = optional(bool, false)
    sharing_status                     = optional(string, "NOT_SHARED")
    target_name                        = optional(string, null)
    created_by                         = optional(string, null)
    usage_type                         = optional(string, "USER")
    is_hidden                          = optional(bool, false)

    iscsi_features = optional(object({
      enabled_authentications = optional(string, "NONE")
      target_secret           = optional(string, null)
    }), null)

    storage_features = optional(object({
      flash_mode = optional(object({
        is_enabled = optional(bool, false)
      }), null)
    }), null)

    vm_attachments = optional(list(object({
      vm_ext_id = string           # VM UUID
      index     = optional(number) # SCSI bus index
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.volume_groups :
      contains(["SHARED", "NOT_SHARED"], v.sharing_status)
    ])
    error_message = "Volume group 'sharing_status' must be one of: SHARED, NOT_SHARED."
  }

  validation {
    condition = alltrue([
      for k, v in var.volume_groups :
      contains(["BACKUP_TARGET", "INTERNAL", "TEMPORARY", "USER"], v.usage_type)
    ])
    error_message = "Volume group 'usage_type' must be one of: BACKUP_TARGET, INTERNAL, TEMPORARY, USER."
  }
}

##################################################
# Volume Group Disks
##################################################

variable "volume_group_disks" {
  description = "A map of volume group disks to manage in Nutanix."
  type = map(object({
    volume_group_ext_id      = string
    index                    = optional(number, null)
    description              = optional(string, null)
    disk_size_bytes          = number
    storage_container_ext_id = optional(string, null) # Storage container UUID for a new disk (derivation fallback)

    disk_data_source = optional(object({
      recovery_point_ext_id = optional(string, null) # Clone from recovery point
      vm_disk_ext_id        = optional(string, null) # Clone from VM disk
    }), null)

    # Explicit data source reference; when omitted, the reference is derived
    # from disk_data_source (recovery point / VM disk) or storage_container_ext_id.
    disk_data_source_reference = optional(object({
      ext_id      = string
      name        = optional(string, null)
      entity_type = string # STORAGE_CONTAINER, VM_DISK, VOLUME_DISK, DISK_RECOVERY_POINT
      uris        = optional(list(string), [])
    }), null)

    disk_storage_features = optional(object({
      flash_mode = optional(object({
        is_enabled = optional(bool, false)
      }), null)
    }), null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.volume_group_disks :
      v.disk_data_source_reference == null ? true :
      contains(["STORAGE_CONTAINER", "VM_DISK", "VOLUME_DISK", "DISK_RECOVERY_POINT"], v.disk_data_source_reference.entity_type)
    ])
    error_message = "Volume group disk 'entity_type' must be one of: STORAGE_CONTAINER, VM_DISK, VOLUME_DISK, DISK_RECOVERY_POINT."
  }

  validation {
    condition = alltrue([
      for k, v in var.volume_group_disks :
      v.volume_group_ext_id != null && v.volume_group_ext_id != ""
    ])
    error_message = "Volume group disk 'volume_group_ext_id' is required for all volume group disks."
  }

  validation {
    condition = alltrue([
      for k, v in var.volume_group_disks :
      v.disk_data_source_reference != null ||
      try(v.disk_data_source.recovery_point_ext_id, null) != null ||
      try(v.disk_data_source.vm_disk_ext_id, null) != null ||
      (v.storage_container_ext_id != null && v.storage_container_ext_id != "")
    ])
    error_message = "Volume group disks require a data source: set 'disk_data_source_reference', 'disk_data_source', or 'storage_container_ext_id'."
  }

  validation {
    condition = alltrue([
      for k, v in var.volume_group_disks :
      v.disk_size_bytes >= 1073741824
    ])
    error_message = "Volume group disk 'disk_size_bytes' must be at least 1GB (1073741824 bytes)."
  }

  validation {
    condition = alltrue([
      for k, v in var.volume_group_disks :
      v.index == null ? true : v.index >= 0
    ])
    error_message = "Volume group disk 'index' must be a non-negative integer."
  }
}

##################################################
# Storage Policies
##################################################

variable "storage_policies" {
  description = "A map of storage policies (nutanix_storage_policy_v2) to manage in Nutanix. Each policy applies compression, encryption, fault-tolerance and/or IOPS-throttling effects to the entities selected by its referenced categories."
  type = map(object({
    name             = string
    category_ext_ids = optional(set(string), [])

    compression_spec = optional(object({
      compression_state = string # DISABLED, POSTPROCESS, INLINE, SYSTEM_DERIVED
    }), null)

    encryption_spec = optional(object({
      encryption_state = string # SYSTEM_DERIVED, ENABLED
    }), null)

    qos_spec = optional(object({
      throttled_iops = number # 100 - 2147483647
    }), null)

    fault_tolerance_spec = optional(object({
      replication_factor = string # SYSTEM_DERIVED, TWO, THREE
    }), null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.storage_policies :
      v.name != null && v.name != "" && length(v.name) <= 64
    ])
    error_message = "Storage policy 'name' is required and must not exceed 64 characters."
  }

  validation {
    condition = alltrue([
      for k, v in var.storage_policies :
      length(v.category_ext_ids) <= 20
    ])
    error_message = "Storage policy 'category_ext_ids' must reference at most 20 categories."
  }

  validation {
    condition = alltrue([
      for k, v in var.storage_policies :
      v.compression_spec == null ? true :
      contains(["DISABLED", "POSTPROCESS", "INLINE", "SYSTEM_DERIVED"], v.compression_spec.compression_state)
    ])
    error_message = "Storage policy 'compression_state' must be one of: DISABLED, POSTPROCESS, INLINE, SYSTEM_DERIVED."
  }

  validation {
    condition = alltrue([
      for k, v in var.storage_policies :
      v.encryption_spec == null ? true :
      contains(["SYSTEM_DERIVED", "ENABLED"], v.encryption_spec.encryption_state)
    ])
    error_message = "Storage policy 'encryption_state' must be one of: SYSTEM_DERIVED, ENABLED."
  }

  validation {
    condition = alltrue([
      for k, v in var.storage_policies :
      v.fault_tolerance_spec == null ? true :
      contains(["SYSTEM_DERIVED", "TWO", "THREE"], v.fault_tolerance_spec.replication_factor)
    ])
    error_message = "Storage policy 'replication_factor' must be one of: SYSTEM_DERIVED, TWO, THREE."
  }

  validation {
    condition = alltrue([
      for k, v in var.storage_policies :
      v.qos_spec == null ? true :
      v.qos_spec.throttled_iops >= 100 && v.qos_spec.throttled_iops <= 2147483647
    ])
    error_message = "Storage policy 'throttled_iops' must be between 100 and 2147483647."
  }
}

##################################################
# Volume Group iSCSI Clients
##################################################

variable "volume_group_iscsi_clients" {
  description = "A map of external iSCSI initiator clients to attach to volume groups. Each entry references a volume group by 'volume_group' (a key of var.volume_groups for a module-created VG, or a raw VG ext_id for a pre-existing one) and identifies the initiator by IQN ('iscsi_initiator_name') or network address ('iscsi_initiator_network_id'). CHAP secrets are NOT set here — supply them via the sensitive 'volume_group_iscsi_client_secrets' map."
  type = map(object({
    volume_group            = string                   # key of var.volume_groups, or a VG ext_id
    iscsi_initiator_name    = optional(string, null)   # iSCSI initiator IQN (immutable)
    enabled_authentications = optional(string, "NONE") # NONE or CHAP
    attachment_site         = optional(string, null)   # only valid when Metro DR is configured
    num_virtual_targets     = optional(number, null)   # immutable

    iscsi_initiator_network_id = optional(object({
      ipv4 = optional(object({
        value         = string
        prefix_length = optional(number, 32)
      }), null)
      ipv6 = optional(object({
        value         = string
        prefix_length = optional(number, 128)
      }), null)
      fqdn = optional(object({
        value = string
      }), null)
    }), null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.volume_group_iscsi_clients :
      v.volume_group != null && v.volume_group != ""
    ])
    error_message = "Each iSCSI client must reference a non-empty 'volume_group' (a var.volume_groups key or a VG ext_id)."
  }

  validation {
    condition = alltrue([
      for k, v in var.volume_group_iscsi_clients :
      (v.iscsi_initiator_name != null && v.iscsi_initiator_name != "") != (v.iscsi_initiator_network_id != null)
    ])
    error_message = "Each iSCSI client must set exactly one of 'iscsi_initiator_name' or 'iscsi_initiator_network_id'."
  }

  validation {
    condition = alltrue([
      for k, v in var.volume_group_iscsi_clients :
      v.iscsi_initiator_name == null ? true : can(regex("^(iqn|eui)\\.", v.iscsi_initiator_name))
    ])
    error_message = "iSCSI 'iscsi_initiator_name' must be a valid IQN (starts with 'iqn.') or EUI ('eui.')."
  }

  validation {
    condition = alltrue([
      for k, v in var.volume_group_iscsi_clients :
      contains(["NONE", "CHAP"], v.enabled_authentications)
    ])
    error_message = "iSCSI 'enabled_authentications' must be one of: NONE, CHAP."
  }
}

variable "volume_group_iscsi_client_secrets" {
  description = "Map of iSCSI client key => CHAP client secret. Isolated from the plaintext 'volume_group_iscsi_clients' map so that authentication secrets never enter YAML config. Only consulted for clients whose 'enabled_authentications' is CHAP."
  type        = map(string)
  default     = {}
  sensitive   = true
}

##################################################
# Volume Group Category Associations
##################################################

variable "volume_group_category_associations" {
  description = "A map of volume-group category associations. Each entry references a volume group by 'volume_group' (a key of var.volume_groups, or a raw VG ext_id) and a list of categories. A category is referenced directly by 'ext_id', or by 'name' in \"key/value\" form which is resolved to an ext_id via the gated categories_v2 lookup (requires enable_data_lookups = true)."
  type = map(object({
    volume_group = string # key of var.volume_groups, or a VG ext_id
    categories = list(object({
      ext_id      = optional(string, null)       # category ext_id (passthrough)
      name        = optional(string, null)       # "key/value" resolved via categories_v2 lookup when ext_id omitted
      entity_type = optional(string, "CATEGORY") # entity type of the category reference
      uris        = optional(list(string), [])
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.volume_group_category_associations :
      v.volume_group != null && v.volume_group != ""
    ])
    error_message = "Each category association must reference a non-empty 'volume_group' (a var.volume_groups key or a VG ext_id)."
  }

  validation {
    condition = alltrue([
      for k, v in var.volume_group_category_associations :
      length(v.categories) > 0
    ])
    error_message = "Each category association must reference at least one category."
  }

  validation {
    condition = alltrue([
      for k, v in var.volume_group_category_associations :
      alltrue([
        for c in v.categories :
        (c.ext_id != null && c.ext_id != "") || (c.name != null && c.name != "")
      ])
    ])
    error_message = "Each category reference must supply either 'ext_id' or 'name'."
  }
}

##################################################
# Data Lookups
##################################################

variable "enable_data_lookups" {
  description = "When true, enable the gated read-only data source lookups (e.g. existing storage policies). Off by default so plans do not require live Prism Central connectivity."
  type        = bool
  default     = false
}

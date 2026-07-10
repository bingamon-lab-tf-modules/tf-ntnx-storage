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
    volume_group_ext_id = string
    index               = optional(number, null)
    description         = optional(string, null)
    disk_size_bytes     = number

    disk_data_source_reference = object({
      ext_id      = string
      name        = optional(string, null)
      entity_type = string # STORAGE_CONTAINER, VM_DISK, VOLUME_DISK, DISK_RECOVERY_POINT
      uris        = optional(list(string), [])
    })

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
      contains(["STORAGE_CONTAINER", "VM_DISK", "VOLUME_DISK", "DISK_RECOVERY_POINT"], v.disk_data_source_reference.entity_type)
    ])
    error_message = "Volume group disk 'entity_type' must be one of: STORAGE_CONTAINER, VM_DISK, VOLUME_DISK, DISK_RECOVERY_POINT."
  }
}

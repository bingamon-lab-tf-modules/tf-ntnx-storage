##################################################
# Nutanix Storage Module - Complete Example
##################################################

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = ">= 2.4.2"
    }
  }
}

provider "nutanix" {
  username = var.nutanix_username
  password = var.nutanix_password
  endpoint = var.nutanix_endpoint
  insecure = var.nutanix_insecure
}

##################################################
# Storage Module
##################################################

module "storage" {
  source = "../../module"

  # Storage Containers
  storage_containers = {
    default = {
      name                   = "default-container"
      cluster_ext_id         = var.cluster_ext_id
      replication_factor     = 2
      is_compression_enabled = true
      compression_delay_secs = 0
      cache_deduplication    = "OFF"
      on_disk_dedup          = "OFF"
      erasure_code           = "OFF"
    }

    high_performance = {
      name                   = "high-perf-container"
      cluster_ext_id         = var.cluster_ext_id
      replication_factor     = 2
      is_compression_enabled = false
    }
  }

  # Volume Groups
  volume_groups = {
    database = {
      name              = "database-vg"
      description       = "Volume group for database storage"
      cluster_reference = var.cluster_ext_id
      sharing_status    = "NOT_SHARED"
      usage_type        = "USER"

      # Attach the volume group to an existing VM.
      vm_attachments = [
        {
          vm_ext_id = var.vm_ext_id
          index     = 0
        }
      ]
    }

    shared_storage = {
      name              = "shared-vg"
      description       = "Shared volume group for cluster"
      cluster_reference = var.cluster_ext_id
      sharing_status    = "SHARED"
      usage_type        = "USER"

      iscsi_features = {
        enabled_authentications = "NONE"
      }

      storage_features = {
        flash_mode = {
          is_enabled = false
        }
      }
    }
  }

  # Volume Group Disks (attached to existing volume groups)
  volume_group_disks = {
    database_data = {
      volume_group_ext_id      = var.volume_group_ext_id
      index                    = 0
      description              = "Data disk with a derived storage container data source"
      disk_size_bytes          = 107374182400 # 100GB
      storage_container_ext_id = var.storage_container_ext_id
    }

    database_logs = {
      volume_group_ext_id = var.volume_group_ext_id
      index               = 1
      description         = "Log disk with an explicit disk data source reference"
      disk_size_bytes     = 53687091200 # 50GB

      disk_data_source_reference = {
        ext_id      = var.storage_container_ext_id
        entity_type = "STORAGE_CONTAINER"
      }
    }
  }

  # Storage Policies (category-driven QoS: compression, encryption, throttling)
  storage_policies = {
    gold = {
      name             = "gold"
      category_ext_ids = [var.category_ext_id]

      compression_spec = {
        compression_state = "INLINE"
      }

      encryption_spec = {
        encryption_state = "ENABLED"
      }

      qos_spec = {
        throttled_iops = 5000
      }

      fault_tolerance_spec = {
        replication_factor = "THREE"
      }
    }
  }
}

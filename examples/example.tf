terraform {
  required_version = ">= 1.9.0"
}

module "storage" {
  source = "git::https://github.com/bingamon-lab-tf-modules/tf-ntnx-storage.git//module?ref=v0.1.0"

  ##################################################
  # Storage Containers
  ##################################################

  storage_containers = {
    default = {
      name                   = "default-container"
      cluster_ext_id         = "00000000-0000-0000-0000-000000000000"
      replication_factor     = 2
      is_compression_enabled = true
      compression_delay_secs = 0
      erasure_code           = "OFF"
      cache_deduplication    = "OFF"
      on_disk_dedup          = "OFF"
    }
  }

  ##################################################
  # Volume Groups
  ##################################################

  volume_groups = {
    database = {
      name              = "database-vg"
      description       = "Volume group for database storage"
      cluster_reference = "00000000-0000-0000-0000-000000000000"
      sharing_status    = "NOT_SHARED"
      usage_type        = "USER"

      # Attach the volume group to an existing VM (iSCSI/VM attachment surface).
      vm_attachments = [
        {
          vm_ext_id = "11111111-1111-1111-1111-111111111111"
          index     = 0
        }
      ]
    }
  }

  ##################################################
  # Volume Group Disks
  ##################################################

  volume_group_disks = {
    data = {
      volume_group_ext_id      = "22222222-2222-2222-2222-222222222222"
      index                    = 0
      description              = "Primary data disk (storage-container data source)"
      disk_size_bytes          = 107374182400 # 100 GB
      storage_container_ext_id = "33333333-3333-3333-3333-333333333333"
    }

    logs = {
      volume_group_ext_id = "22222222-2222-2222-2222-222222222222"
      index               = 1
      description         = "Log disk with an explicit disk data source reference"
      disk_size_bytes     = 53687091200 # 50 GB

      disk_data_source_reference = {
        ext_id      = "33333333-3333-3333-3333-333333333333"
        entity_type = "STORAGE_CONTAINER"
      }
    }
  }
}

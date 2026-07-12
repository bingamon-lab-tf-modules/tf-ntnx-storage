##################################################
# Unit Tests: Storage (containers, volume groups,
# disks, VM attachments) — mock_provider only.
##################################################

#########################
# Provider
#########################

provider "nutanix" {
  username     = "dummy"
  password     = "dummy"
  endpoint     = "dummy.local"
  port         = 9440
  insecure     = true
  wait_timeout = 1
}

#########################
# Mock Data (Nutanix Provider)
#########################

mock_provider "nutanix" {

  # Existing storage containers lookup (empty response)
  mock_data "nutanix_storage_containers_v2" {
    defaults = {
      storage_containers = []
    }
  }

  # Existing volume groups lookup (empty response)
  mock_data "nutanix_volume_groups_v2" {
    defaults = {
      volumes = []
    }
  }

  # Cluster lookup for container / volume group placement
  mock_data "nutanix_clusters_v2" {
    defaults = {
      cluster_entities = [
        {
          ext_id                   = "00000000-0000-0000-0000-000000000000"
          name                     = "mock-cluster"
          backup_eligibility_score = 0
          categories               = []
          cluster_profile_ext_id   = ""
          container_name           = ""
          expand                   = ""
          inefficient_vm_count     = 0
          links                    = []
          network                  = []
          nodes                    = []
          tenant_id                = ""
          upgrade_status           = ""
          vm_count                 = 0
          config = [
            {
              authorized_public_key_list       = []
              build_info                       = []
              cluster_arch                     = ""
              cluster_function                 = ["AOS"]
              cluster_software_map             = []
              encryption_in_transit_status     = ""
              encryption_option                = []
              encryption_scope                 = []
              fault_tolerance_state            = []
              hypervisor_types                 = ["AHV"]
              incarnation_id                   = 0
              is_available                     = true
              is_lts                           = false
              is_password_remote_login_enabled = false
              is_remote_support_enabled        = false
              operation_mode                   = ""
              pulse_status                     = []
              redundancy_factor                = 2
              timezone                         = ""
            }
          ]
        }
      ]
    }
  }
}

#########################
# Tests
#########################

# Test 1: Empty configuration plans zero managed resources.
run "empty_config" {
  command = plan

  variables {
    storage_containers = {}
    volume_groups      = {}
    volume_group_disks = {}
  }

  assert {
    condition     = output.storage_summary.total_storage_containers == 0
    error_message = "Expected 0 storage containers for empty config"
  }

  assert {
    condition     = output.storage_summary.total_volume_groups == 0
    error_message = "Expected 0 volume groups for empty config"
  }

  assert {
    condition     = output.storage_summary.total_volume_group_disks == 0
    error_message = "Expected 0 volume group disks for empty config"
  }

  assert {
    condition     = length(output.storage_container_ids) == 0
    error_message = "Expected empty storage_container_ids map"
  }
}

# Test 2: Containers, volume groups, and disks produce id-map outputs.
run "containers_volume_groups_and_disks" {
  command = plan

  variables {
    storage_containers = {
      default = {
        name                   = "default-container"
        cluster_ext_id         = "00000000-0000-0000-0000-000000000000"
        replication_factor     = 2
        is_compression_enabled = true
        erasure_code           = "OFF"
      }
    }

    volume_groups = {
      database = {
        name              = "database-vg"
        cluster_reference = "00000000-0000-0000-0000-000000000000"
        sharing_status    = "NOT_SHARED"
        usage_type        = "USER"
      }
    }

    volume_group_disks = {
      data = {
        volume_group_ext_id      = "22222222-2222-2222-2222-222222222222"
        index                    = 0
        disk_size_bytes          = 107374182400
        storage_container_ext_id = "33333333-3333-3333-3333-333333333333"
      }
      logs = {
        volume_group_ext_id = "22222222-2222-2222-2222-222222222222"
        index               = 1
        disk_size_bytes     = 53687091200
        disk_data_source_reference = {
          ext_id      = "33333333-3333-3333-3333-333333333333"
          entity_type = "STORAGE_CONTAINER"
        }
      }
    }
  }

  assert {
    condition     = output.storage_summary.total_storage_containers == 1
    error_message = "Expected 1 storage container"
  }

  assert {
    condition     = output.storage_summary.total_volume_groups == 1
    error_message = "Expected 1 volume group"
  }

  assert {
    condition     = output.storage_summary.total_volume_group_disks == 2
    error_message = "Expected 2 volume group disks"
  }

  assert {
    condition     = output.storage_summary.compressed_containers == 1
    error_message = "Expected 1 compressed container"
  }

  assert {
    condition     = contains(keys(output.storage_container_ids), "default")
    error_message = "Expected storage_container_ids to contain the 'default' key"
  }

  assert {
    condition     = contains(keys(output.volume_group_ids), "database")
    error_message = "Expected volume_group_ids to contain the 'database' key"
  }

  assert {
    condition     = length(output.volume_group_disk_ids) == 2
    error_message = "Expected 2 entries in volume_group_disk_ids"
  }
}

# Test 3: Volume group VM attachment surface (harvested via issue 524).
run "volume_group_vm_attachment" {
  command = plan

  variables {
    volume_groups = {
      database = {
        name              = "database-vg"
        cluster_reference = "00000000-0000-0000-0000-000000000000"
        vm_attachments = [
          {
            vm_ext_id = "11111111-1111-1111-1111-111111111111"
            index     = 0
          }
        ]
      }
    }
  }

  assert {
    condition     = length(output.volume_group_vm_attachments) == 1
    error_message = "Expected 1 volume group VM attachment"
  }

  assert {
    condition     = contains(keys(output.volume_group_vm_attachments), "database-vm-0")
    error_message = "Expected VM attachment key 'database-vm-0'"
  }
}

# Test 4: Shared volume group with iSCSI features is summarised.
run "shared_iscsi_volume_group" {
  command = plan

  variables {
    volume_groups = {
      shared = {
        name              = "shared-vg"
        cluster_reference = "00000000-0000-0000-0000-000000000000"
        sharing_status    = "SHARED"
        usage_type        = "USER"
        iscsi_features = {
          enabled_authentications = "NONE"
        }
      }
    }
  }

  assert {
    condition     = output.storage_summary.shared_volume_groups == 1
    error_message = "Expected 1 shared volume group"
  }
}

# Test 5: Invalid storage container erasure_code enum fails validation.
run "invalid_erasure_code" {
  command = plan

  variables {
    storage_containers = {
      bad = {
        name           = "bad-container"
        cluster_ext_id = "00000000-0000-0000-0000-000000000000"
        erasure_code   = "INVALID"
      }
    }
  }

  expect_failures = [var.storage_containers]
}

# Test 6: Invalid volume group sharing_status enum fails validation.
run "invalid_sharing_status" {
  command = plan

  variables {
    volume_groups = {
      bad = {
        name              = "bad-vg"
        cluster_reference = "00000000-0000-0000-0000-000000000000"
        sharing_status    = "INVALID"
      }
    }
  }

  expect_failures = [var.volume_groups]
}

# Test 7: Invalid volume group usage_type enum fails validation.
run "invalid_usage_type" {
  command = plan

  variables {
    volume_groups = {
      bad = {
        name              = "bad-vg"
        cluster_reference = "00000000-0000-0000-0000-000000000000"
        usage_type        = "INVALID"
      }
    }
  }

  expect_failures = [var.volume_groups]
}

# Test 8: Volume group disk smaller than 1 GiB fails validation.
run "disk_too_small" {
  command = plan

  variables {
    volume_group_disks = {
      tiny = {
        volume_group_ext_id      = "22222222-2222-2222-2222-222222222222"
        disk_size_bytes          = 1048576 # 1 MiB — below the 1 GiB minimum
        storage_container_ext_id = "33333333-3333-3333-3333-333333333333"
      }
    }
  }

  expect_failures = [var.volume_group_disks]
}

# Test 9: Volume group disk without any data source fails validation.
run "disk_missing_data_source" {
  command = plan

  variables {
    volume_group_disks = {
      orphan = {
        volume_group_ext_id = "22222222-2222-2222-2222-222222222222"
        disk_size_bytes     = 107374182400
      }
    }
  }

  expect_failures = [var.volume_group_disks]
}

# Test 10: Invalid disk data source entity_type enum fails validation.
run "invalid_entity_type" {
  command = plan

  variables {
    volume_group_disks = {
      bad = {
        volume_group_ext_id = "22222222-2222-2222-2222-222222222222"
        disk_size_bytes     = 107374182400
        disk_data_source_reference = {
          ext_id      = "33333333-3333-3333-3333-333333333333"
          entity_type = "INVALID"
        }
      }
    }
  }

  expect_failures = [var.volume_group_disks]
}

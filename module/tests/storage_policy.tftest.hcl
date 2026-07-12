##################################################
# Unit Tests: Storage Policies
# (nutanix_storage_policy_v2) — mock_provider only.
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

  # Existing storage policies lookup (gated; empty response)
  mock_data "nutanix_storage_policies_v2" {
    defaults = {
      storage_policies = []
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

# Test 1: Empty configuration plans zero storage policies.
run "empty_policies" {
  command = plan

  variables {
    storage_policies = {}
  }

  assert {
    condition     = output.storage_summary.total_storage_policies == 0
    error_message = "Expected 0 storage policies for empty config"
  }

  assert {
    condition     = length(output.storage_policy_ids) == 0
    error_message = "Expected empty storage_policy_ids map"
  }
}

# Test 2: Policies with effects and categories produce id-map outputs.
run "policies_produce_id_maps" {
  command = plan

  variables {
    storage_policies = {
      gold = {
        name             = "gold"
        category_ext_ids = ["4d552748-e119-540a-b06c-3c6f0d213fa2"]

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

      silver = {
        name             = "silver"
        category_ext_ids = ["5e663859-f22a-651b-c17d-4d701e324gb3"]

        qos_spec = {
          throttled_iops = 1000
        }
      }
    }
  }

  assert {
    condition     = output.storage_summary.total_storage_policies == 2
    error_message = "Expected 2 storage policies"
  }

  assert {
    condition     = output.storage_summary.compression_policies == 1
    error_message = "Expected 1 policy with a compression effect"
  }

  assert {
    condition     = output.storage_summary.encrypted_policies == 1
    error_message = "Expected 1 policy with an encryption effect"
  }

  assert {
    condition     = output.storage_summary.throttled_policies == 2
    error_message = "Expected 2 policies with a QoS throttling effect"
  }

  assert {
    condition     = contains(keys(output.storage_policy_ids), "gold")
    error_message = "Expected storage_policy_ids to contain the 'gold' key"
  }

  assert {
    condition     = length(output.storage_policy_ids) == 2
    error_message = "Expected 2 entries in storage_policy_ids"
  }
}

# Test 3: Gated data lookup toggles on without breaking the plan.
run "enable_data_lookups" {
  command = plan

  variables {
    enable_data_lookups = true

    storage_policies = {
      bronze = {
        name             = "bronze"
        category_ext_ids = ["4d552748-e119-540a-b06c-3c6f0d213fa2"]
        qos_spec = {
          throttled_iops = 500
        }
      }
    }
  }

  assert {
    condition     = output.storage_summary.total_storage_policies == 1
    error_message = "Expected 1 storage policy with data lookups enabled"
  }
}

# Test 4: Invalid compression_state enum fails validation.
run "invalid_compression_state" {
  command = plan

  variables {
    storage_policies = {
      bad = {
        name             = "bad"
        category_ext_ids = ["4d552748-e119-540a-b06c-3c6f0d213fa2"]
        compression_spec = {
          compression_state = "INVALID"
        }
      }
    }
  }

  expect_failures = [var.storage_policies]
}

# Test 5: Invalid encryption_state enum fails validation.
run "invalid_encryption_state" {
  command = plan

  variables {
    storage_policies = {
      bad = {
        name             = "bad"
        category_ext_ids = ["4d552748-e119-540a-b06c-3c6f0d213fa2"]
        encryption_spec = {
          encryption_state = "DISABLED"
        }
      }
    }
  }

  expect_failures = [var.storage_policies]
}

# Test 6: Invalid fault-tolerance replication_factor enum fails validation.
run "invalid_replication_factor" {
  command = plan

  variables {
    storage_policies = {
      bad = {
        name             = "bad"
        category_ext_ids = ["4d552748-e119-540a-b06c-3c6f0d213fa2"]
        fault_tolerance_spec = {
          replication_factor = "FOUR"
        }
      }
    }
  }

  expect_failures = [var.storage_policies]
}

# Test 7: throttled_iops below the minimum fails validation.
run "invalid_throttled_iops" {
  command = plan

  variables {
    storage_policies = {
      bad = {
        name             = "bad"
        category_ext_ids = ["4d552748-e119-540a-b06c-3c6f0d213fa2"]
        qos_spec = {
          throttled_iops = 10 # below the 100 minimum
        }
      }
    }
  }

  expect_failures = [var.storage_policies]
}

# Test 8: Policy name longer than 64 characters fails validation.
run "invalid_policy_name_length" {
  command = plan

  variables {
    storage_policies = {
      bad = {
        name             = "this-storage-policy-name-is-deliberately-far-too-long-to-be-accepted-by-the-backend"
        category_ext_ids = ["4d552748-e119-540a-b06c-3c6f0d213fa2"]
        qos_spec = {
          throttled_iops = 1000
        }
      }
    }
  }

  expect_failures = [var.storage_policies]
}

##################################################
# Unit Tests: Volume Group iSCSI Clients and
# Category Associations — mock_provider only.
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

  # Existing volume-group iSCSI clients lookup (gated; empty response)
  mock_data "nutanix_volume_iscsi_clients_v2" {
    defaults = {
      iscsi_clients = []
    }
  }

  # Existing categories lookup (gated; empty response)
  mock_data "nutanix_categories_v2" {
    defaults = {
      categories = []
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

# Test 1: Empty configuration plans zero iSCSI clients and category associations.
run "empty_attachments" {
  command = plan

  variables {
    volume_group_iscsi_clients         = {}
    volume_group_category_associations = {}
  }

  assert {
    condition     = output.storage_summary.total_volume_group_iscsi_clients == 0
    error_message = "Expected 0 iSCSI clients for empty config"
  }

  assert {
    condition     = output.storage_summary.total_volume_group_category_associations == 0
    error_message = "Expected 0 category associations for empty config"
  }

  assert {
    condition     = length(output.volume_group_iscsi_client_ids) == 0
    error_message = "Expected empty volume_group_iscsi_client_ids map"
  }

  assert {
    condition     = length(output.volume_group_category_associations) == 0
    error_message = "Expected empty volume_group_category_associations map"
  }
}

# Test 2: iSCSI client and category association referencing a module-created VG
# by key resolve without error and surface in the outputs.
run "attachments_by_module_key" {
  command = plan

  variables {
    volume_groups = {
      database = {
        name              = "database-vg"
        cluster_reference = "00000000-0000-0000-0000-000000000000"
      }
    }

    volume_group_iscsi_clients = {
      db_host = {
        volume_group         = "database"
        iscsi_initiator_name = "iqn.1991-05.com.microsoft:host1"
      }
    }

    volume_group_category_associations = {
      data_vg_tier = {
        volume_group = "database"
        categories = [
          {
            ext_id = "55555555-5555-5555-5555-555555555555"
          }
        ]
      }
    }
  }

  assert {
    condition     = output.storage_summary.total_volume_group_iscsi_clients == 1
    error_message = "Expected 1 iSCSI client"
  }

  assert {
    condition     = output.storage_summary.total_volume_group_category_associations == 1
    error_message = "Expected 1 category association"
  }

  assert {
    condition     = contains(keys(output.volume_group_iscsi_client_ids), "db_host")
    error_message = "Expected volume_group_iscsi_client_ids to contain the 'db_host' key"
  }

  assert {
    condition     = output.volume_group_iscsi_clients["db_host"].iscsi_initiator_name == "iqn.1991-05.com.microsoft:host1"
    error_message = "Expected the iSCSI client IQN to pass through unchanged"
  }

  assert {
    condition     = output.volume_group_iscsi_clients["db_host"].enabled_authentications == "NONE"
    error_message = "Expected default enabled_authentications of NONE"
  }

  assert {
    condition     = contains(keys(output.volume_group_category_associations), "data_vg_tier")
    error_message = "Expected volume_group_category_associations to contain the 'data_vg_tier' key"
  }
}

# Test 3: References to a pre-existing VG ext_id pass through to the resolved
# vg_ext_id in-plan (proving ext_id passthrough for pre-existing VGs).
run "attachments_by_ext_id_passthrough" {
  command = plan

  variables {
    volume_group_iscsi_clients = {
      external_host = {
        volume_group         = "99999999-9999-9999-9999-999999999999"
        iscsi_initiator_name = "iqn.1991-05.com.microsoft:host2"
      }
    }

    volume_group_category_associations = {
      external_tier = {
        volume_group = "99999999-9999-9999-9999-999999999999"
        categories = [
          {
            ext_id = "55555555-5555-5555-5555-555555555555"
          }
        ]
      }
    }
  }

  assert {
    condition     = output.volume_group_iscsi_clients["external_host"].vg_ext_id == "99999999-9999-9999-9999-999999999999"
    error_message = "Expected iSCSI client vg_ext_id to pass through the pre-existing VG ext_id"
  }

  assert {
    condition     = output.volume_group_category_associations["external_tier"].vg_ext_id == "99999999-9999-9999-9999-999999999999"
    error_message = "Expected category association vg_ext_id to pass through the pre-existing VG ext_id"
  }
}

# Test 4: A CHAP iSCSI client sources its secret from the sensitive secrets map.
run "chap_client_secret_via_sensitive_var" {
  command = plan

  variables {
    volume_groups = {
      database = {
        name              = "database-vg"
        cluster_reference = "00000000-0000-0000-0000-000000000000"
      }
    }

    volume_group_iscsi_clients = {
      secure_host = {
        volume_group            = "database"
        iscsi_initiator_name    = "iqn.1991-05.com.microsoft:host3"
        enabled_authentications = "CHAP"
      }
    }

    volume_group_iscsi_client_secrets = {
      secure_host = "super-secret-chap-password"
    }
  }

  assert {
    condition     = output.storage_summary.chap_iscsi_clients == 1
    error_message = "Expected 1 CHAP iSCSI client"
  }

  assert {
    condition     = output.volume_group_iscsi_clients["secure_host"].enabled_authentications == "CHAP"
    error_message = "Expected the iSCSI client to use CHAP authentication"
  }
}

# Test 5: Invalid IQN format fails validation.
run "invalid_iqn_format" {
  command = plan

  variables {
    volume_group_iscsi_clients = {
      bad = {
        volume_group         = "99999999-9999-9999-9999-999999999999"
        iscsi_initiator_name = "not-a-valid-iqn"
      }
    }
  }

  expect_failures = [var.volume_group_iscsi_clients]
}

# Test 6: An iSCSI client with neither an IQN nor a network id fails validation.
run "iscsi_client_missing_initiator" {
  command = plan

  variables {
    volume_group_iscsi_clients = {
      bad = {
        volume_group = "99999999-9999-9999-9999-999999999999"
      }
    }
  }

  expect_failures = [var.volume_group_iscsi_clients]
}

# Test 7: Invalid enabled_authentications enum fails validation.
run "invalid_enabled_authentications" {
  command = plan

  variables {
    volume_group_iscsi_clients = {
      bad = {
        volume_group            = "99999999-9999-9999-9999-999999999999"
        iscsi_initiator_name    = "iqn.1991-05.com.microsoft:host4"
        enabled_authentications = "MUTUAL_CHAP"
      }
    }
  }

  expect_failures = [var.volume_group_iscsi_clients]
}

# Test 8: A category reference with neither ext_id nor name fails validation.
run "category_reference_missing_ref" {
  command = plan

  variables {
    volume_group_category_associations = {
      bad = {
        volume_group = "99999999-9999-9999-9999-999999999999"
        categories = [
          {
            entity_type = "CATEGORY"
          }
        ]
      }
    }
  }

  expect_failures = [var.volume_group_category_associations]
}

# Test 9: A category association with an empty category list fails validation.
run "category_association_empty_list" {
  command = plan

  variables {
    volume_group_category_associations = {
      bad = {
        volume_group = "99999999-9999-9999-9999-999999999999"
        categories   = []
      }
    }
  }

  expect_failures = [var.volume_group_category_associations]
}

##################################################
# Data Sources for Storage
##################################################

# Lookup existing storage containers
data "nutanix_storage_containers_v2" "existing_containers" {}

# Lookup existing volume groups
data "nutanix_volume_groups_v2" "existing_volume_groups" {}

# Lookup clusters for container placement
data "nutanix_clusters_v2" "clusters" {}

# Lookup existing storage policies (gated; disabled by default)
data "nutanix_storage_policies_v2" "existing_policies" {
  count = var.enable_data_lookups ? 1 : 0
}

# Lookup existing volume-group iSCSI clients (gated; disabled by default)
data "nutanix_volume_iscsi_clients_v2" "existing_iscsi_clients" {
  count = var.enable_data_lookups ? 1 : 0
}

# Lookup existing categories for category name -> ext_id resolution (gated; disabled by default)
data "nutanix_categories_v2" "existing_categories" {
  count = var.enable_data_lookups ? 1 : 0
}

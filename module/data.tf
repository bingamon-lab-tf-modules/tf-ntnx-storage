##################################################
# Data Sources for Storage
##################################################

# Lookup existing storage containers
data "nutanix_storage_containers_v2" "existing_containers" {}

# Lookup existing volume groups
data "nutanix_volume_groups_v2" "existing_volume_groups" {}

# Lookup clusters for container placement
data "nutanix_clusters_v2" "clusters" {}

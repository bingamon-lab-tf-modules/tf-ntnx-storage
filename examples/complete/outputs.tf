##################################################
# Storage Container Outputs
##################################################

output "storage_containers" {
  description = "Map of created storage containers"
  value       = module.storage.storage_containers
}

output "storage_container_ids" {
  description = "Map of storage container keys to their IDs"
  value       = module.storage.storage_container_ids
}

##################################################
# Volume Group Outputs
##################################################

output "volume_groups" {
  description = "Map of created volume groups"
  value       = module.storage.volume_groups
}

output "volume_group_ids" {
  description = "Map of volume group keys to their IDs"
  value       = module.storage.volume_group_ids
}

##################################################
# Volume Group Disk Outputs
##################################################

output "volume_group_disks" {
  description = "Map of volume group disks"
  value       = module.storage.volume_group_disks
}

output "volume_group_disk_ids" {
  description = "Map of volume group disk keys to their IDs"
  value       = module.storage.volume_group_disk_ids
}

##################################################
# Volume Group VM Attachment Outputs
##################################################

output "volume_group_vm_attachments" {
  description = "Map of volume group VM attachments"
  value       = module.storage.volume_group_vm_attachments
}

##################################################
# Storage Policy Outputs
##################################################

output "storage_policies" {
  description = "Map of created storage policies"
  value       = module.storage.storage_policies
}

output "storage_policy_ids" {
  description = "Map of storage policy keys to their IDs"
  value       = module.storage.storage_policy_ids
}

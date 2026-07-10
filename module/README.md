# tf-ntnx-storage

## Table of Contents

## Overview

A description of the module goes here.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_nutanix"></a> [nutanix](#requirement\_nutanix) | >= 2.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_nutanix"></a> [nutanix](#provider\_nutanix) | 2.4.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [nutanix_storage_containers_v2.container](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/storage_containers_v2) | resource |
| [nutanix_volume_group_disk_v2.disk](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/volume_group_disk_v2) | resource |
| [nutanix_volume_group_v2.volume_group](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/volume_group_v2) | resource |
| [nutanix_clusters_v2.clusters](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/clusters_v2) | data source |
| [nutanix_storage_containers_v2.existing_containers](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/storage_containers_v2) | data source |
| [nutanix_volume_groups_v2.existing_volume_groups](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/volume_groups_v2) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_storage_containers"></a> [storage\_containers](#input\_storage\_containers) | A map of storage containers to manage in Nutanix. | <pre>map(object({<br/>    name                                     = string<br/>    cluster_ext_id                           = string<br/>    logical_advertised_capacity_bytes        = optional(number, null)<br/>    logical_explicit_reserved_capacity_bytes = optional(number, null)<br/>    replication_factor                       = optional(number, null)<br/>    erasure_code                             = optional(string, "OFF")<br/>    is_inline_ec_enabled                     = optional(bool, false)<br/>    has_higher_ec_fault_domain_preference    = optional(bool, false)<br/>    erasure_code_delay_secs                  = optional(number, null)<br/>    cache_deduplication                      = optional(string, "OFF")<br/>    on_disk_dedup                            = optional(string, "OFF")<br/>    is_compression_enabled                   = optional(bool, true)<br/>    compression_delay_secs                   = optional(number, null)<br/>    is_internal                              = optional(bool, false)<br/>    is_software_encryption_enabled           = optional(bool, false)<br/>    affinity_host_ext_id                     = optional(string, null)<br/>    owner_ext_id                             = optional(string, null)<br/><br/>    nfs_whitelist_addresses = optional(list(object({<br/>      ipv4 = optional(object({<br/>        value         = string<br/>        prefix_length = optional(number, 32)<br/>      }), null)<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_volume_group_disks"></a> [volume\_group\_disks](#input\_volume\_group\_disks) | A map of volume group disks to manage in Nutanix. | <pre>map(object({<br/>    volume_group_ext_id = string<br/>    index               = optional(number, null)<br/>    description         = optional(string, null)<br/>    disk_size_bytes     = number<br/><br/>    disk_data_source_reference = object({<br/>      ext_id      = string<br/>      name        = optional(string, null)<br/>      entity_type = string # STORAGE_CONTAINER, VM_DISK, VOLUME_DISK, DISK_RECOVERY_POINT<br/>      uris        = optional(list(string), [])<br/>    })<br/><br/>    disk_storage_features = optional(object({<br/>      flash_mode = optional(object({<br/>        is_enabled = optional(bool, false)<br/>      }), null)<br/>    }), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_volume_groups"></a> [volume\_groups](#input\_volume\_groups) | A map of volume groups to manage in Nutanix. | <pre>map(object({<br/>    name                               = string<br/>    description                        = optional(string, null)<br/>    cluster_reference                  = string<br/>    should_load_balance_vm_attachments = optional(bool, false)<br/>    sharing_status                     = optional(string, "NOT_SHARED")<br/>    target_name                        = optional(string, null)<br/>    created_by                         = optional(string, null)<br/>    usage_type                         = optional(string, "USER")<br/>    is_hidden                          = optional(bool, false)<br/><br/>    iscsi_features = optional(object({<br/>      enabled_authentications = optional(string, "NONE")<br/>      target_secret           = optional(string, null)<br/>    }), null)<br/><br/>    storage_features = optional(object({<br/>      flash_mode = optional(object({<br/>        is_enabled = optional(bool, false)<br/>      }), null)<br/>    }), null)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_container_ids"></a> [storage\_container\_ids](#output\_storage\_container\_ids) | Map of storage container keys to their external IDs. |
| <a name="output_storage_containers"></a> [storage\_containers](#output\_storage\_containers) | Map of created storage containers with their details. |
| <a name="output_storage_summary"></a> [storage\_summary](#output\_storage\_summary) | Summary of storage resources managed by this module. |
| <a name="output_volume_group_disk_ids"></a> [volume\_group\_disk\_ids](#output\_volume\_group\_disk\_ids) | Map of volume group disk keys to their external IDs. |
| <a name="output_volume_group_disks"></a> [volume\_group\_disks](#output\_volume\_group\_disks) | Map of created volume group disks with their details. |
| <a name="output_volume_group_ids"></a> [volume\_group\_ids](#output\_volume\_group\_ids) | Map of volume group keys to their external IDs. |
| <a name="output_volume_groups"></a> [volume\_groups](#output\_volume\_groups) | Map of created volume groups with their details. |
<!-- END_TF_DOCS -->

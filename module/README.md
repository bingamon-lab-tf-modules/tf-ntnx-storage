# tf-ntnx-storage

## Table of Contents

## Overview

A description of the module goes here.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_nutanix"></a> [nutanix](#requirement\_nutanix) | >= 2.4.2 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_nutanix"></a> [nutanix](#provider\_nutanix) | 2.4.2 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [nutanix_associate_category_to_volume_group_v2.category_association](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/associate_category_to_volume_group_v2) | resource |
| [nutanix_storage_containers_v2.container](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/storage_containers_v2) | resource |
| [nutanix_storage_policy_v2.storage_policy](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/storage_policy_v2) | resource |
| [nutanix_volume_group_disk_v2.disk](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/volume_group_disk_v2) | resource |
| [nutanix_volume_group_iscsi_client_v2.iscsi_client](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/volume_group_iscsi_client_v2) | resource |
| [nutanix_volume_group_v2.volume_group](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/volume_group_v2) | resource |
| [nutanix_volume_group_vm_v2.vm_attachment](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/volume_group_vm_v2) | resource |
| [nutanix_categories_v2.existing_categories](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/categories_v2) | data source |
| [nutanix_clusters_v2.clusters](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/clusters_v2) | data source |
| [nutanix_storage_containers_v2.existing_containers](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/storage_containers_v2) | data source |
| [nutanix_storage_policies_v2.existing_policies](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/storage_policies_v2) | data source |
| [nutanix_volume_groups_v2.existing_volume_groups](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/volume_groups_v2) | data source |
| [nutanix_volume_iscsi_clients_v2.existing_iscsi_clients](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/volume_iscsi_clients_v2) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enable_data_lookups"></a> [enable\_data\_lookups](#input\_enable\_data\_lookups) | When true, enable the gated read-only data source lookups (e.g. existing storage policies). Off by default so plans do not require live Prism Central connectivity. | `bool` | `false` | no |
| <a name="input_storage_containers"></a> [storage\_containers](#input\_storage\_containers) | A map of storage containers to manage in Nutanix. | <pre>map(object({<br/>    name                                     = string<br/>    cluster_ext_id                           = string<br/>    logical_advertised_capacity_bytes        = optional(number, null)<br/>    logical_explicit_reserved_capacity_bytes = optional(number, null)<br/>    replication_factor                       = optional(number, null)<br/>    erasure_code                             = optional(string, "OFF")<br/>    is_inline_ec_enabled                     = optional(bool, false)<br/>    has_higher_ec_fault_domain_preference    = optional(bool, false)<br/>    erasure_code_delay_secs                  = optional(number, null)<br/>    cache_deduplication                      = optional(string, "OFF")<br/>    on_disk_dedup                            = optional(string, "OFF")<br/>    is_compression_enabled                   = optional(bool, true)<br/>    compression_delay_secs                   = optional(number, null)<br/>    is_internal                              = optional(bool, false)<br/>    is_software_encryption_enabled           = optional(bool, false)<br/>    affinity_host_ext_id                     = optional(string, null)<br/>    owner_ext_id                             = optional(string, null)<br/><br/>    nfs_whitelist_addresses = optional(list(object({<br/>      ipv4 = optional(object({<br/>        value         = string<br/>        prefix_length = optional(number, 32)<br/>      }), null)<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_storage_policies"></a> [storage\_policies](#input\_storage\_policies) | A map of storage policies (nutanix\_storage\_policy\_v2) to manage in Nutanix. Each policy applies compression, encryption, fault-tolerance and/or IOPS-throttling effects to the entities selected by its referenced categories. | <pre>map(object({<br/>    name             = string<br/>    category_ext_ids = optional(set(string), [])<br/><br/>    compression_spec = optional(object({<br/>      compression_state = string # DISABLED, POSTPROCESS, INLINE, SYSTEM_DERIVED<br/>    }), null)<br/><br/>    encryption_spec = optional(object({<br/>      encryption_state = string # SYSTEM_DERIVED, ENABLED<br/>    }), null)<br/><br/>    qos_spec = optional(object({<br/>      throttled_iops = number # 100 - 2147483647<br/>    }), null)<br/><br/>    fault_tolerance_spec = optional(object({<br/>      replication_factor = string # SYSTEM_DERIVED, TWO, THREE<br/>    }), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_volume_group_category_associations"></a> [volume\_group\_category\_associations](#input\_volume\_group\_category\_associations) | A map of volume-group category associations. Each entry references a volume group by 'volume\_group' (a key of var.volume\_groups, or a raw VG ext\_id) and a list of categories. A category is referenced directly by 'ext\_id', or by 'name' in "key/value" form which is resolved to an ext\_id via the gated categories\_v2 lookup (requires enable\_data\_lookups = true). | <pre>map(object({<br/>    volume_group = string # key of var.volume_groups, or a VG ext_id<br/>    categories = list(object({<br/>      ext_id      = optional(string, null)       # category ext_id (passthrough)<br/>      name        = optional(string, null)       # "key/value" resolved via categories_v2 lookup when ext_id omitted<br/>      entity_type = optional(string, "CATEGORY") # entity type of the category reference<br/>      uris        = optional(list(string), [])<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_volume_group_disks"></a> [volume\_group\_disks](#input\_volume\_group\_disks) | A map of volume group disks to manage in Nutanix. | <pre>map(object({<br/>    volume_group_ext_id      = string<br/>    index                    = optional(number, null)<br/>    description              = optional(string, null)<br/>    disk_size_bytes          = number<br/>    storage_container_ext_id = optional(string, null) # Storage container UUID for a new disk (derivation fallback)<br/><br/>    disk_data_source = optional(object({<br/>      recovery_point_ext_id = optional(string, null) # Clone from recovery point<br/>      vm_disk_ext_id        = optional(string, null) # Clone from VM disk<br/>    }), null)<br/><br/>    # Explicit data source reference; when omitted, the reference is derived<br/>    # from disk_data_source (recovery point / VM disk) or storage_container_ext_id.<br/>    disk_data_source_reference = optional(object({<br/>      ext_id      = string<br/>      name        = optional(string, null)<br/>      entity_type = string # STORAGE_CONTAINER, VM_DISK, VOLUME_DISK, DISK_RECOVERY_POINT<br/>      uris        = optional(list(string), [])<br/>    }), null)<br/><br/>    disk_storage_features = optional(object({<br/>      flash_mode = optional(object({<br/>        is_enabled = optional(bool, false)<br/>      }), null)<br/>    }), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_volume_group_iscsi_client_secrets"></a> [volume\_group\_iscsi\_client\_secrets](#input\_volume\_group\_iscsi\_client\_secrets) | Map of iSCSI client key => CHAP client secret. Isolated from the plaintext 'volume\_group\_iscsi\_clients' map so that authentication secrets never enter YAML config. Only consulted for clients whose 'enabled\_authentications' is CHAP. | `map(string)` | `{}` | no |
| <a name="input_volume_group_iscsi_clients"></a> [volume\_group\_iscsi\_clients](#input\_volume\_group\_iscsi\_clients) | A map of external iSCSI initiator clients to attach to volume groups. Each entry references a volume group by 'volume\_group' (a key of var.volume\_groups for a module-created VG, or a raw VG ext\_id for a pre-existing one) and identifies the initiator by IQN ('iscsi\_initiator\_name') or network address ('iscsi\_initiator\_network\_id'). CHAP secrets are NOT set here — supply them via the sensitive 'volume\_group\_iscsi\_client\_secrets' map. | <pre>map(object({<br/>    volume_group            = string                   # key of var.volume_groups, or a VG ext_id<br/>    iscsi_initiator_name    = optional(string, null)   # iSCSI initiator IQN (immutable)<br/>    enabled_authentications = optional(string, "NONE") # NONE or CHAP<br/>    attachment_site         = optional(string, null)   # only valid when Metro DR is configured<br/>    num_virtual_targets     = optional(number, null)   # immutable<br/><br/>    iscsi_initiator_network_id = optional(object({<br/>      ipv4 = optional(object({<br/>        value         = string<br/>        prefix_length = optional(number, 32)<br/>      }), null)<br/>      ipv6 = optional(object({<br/>        value         = string<br/>        prefix_length = optional(number, 128)<br/>      }), null)<br/>      fqdn = optional(object({<br/>        value = string<br/>      }), null)<br/>    }), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_volume_groups"></a> [volume\_groups](#input\_volume\_groups) | A map of volume groups to manage in Nutanix. | <pre>map(object({<br/>    name                               = string<br/>    description                        = optional(string, null)<br/>    cluster_reference                  = string<br/>    should_load_balance_vm_attachments = optional(bool, false)<br/>    sharing_status                     = optional(string, "NOT_SHARED")<br/>    target_name                        = optional(string, null)<br/>    created_by                         = optional(string, null)<br/>    usage_type                         = optional(string, "USER")<br/>    is_hidden                          = optional(bool, false)<br/><br/>    iscsi_features = optional(object({<br/>      enabled_authentications = optional(string, "NONE")<br/>      target_secret           = optional(string, null)<br/>    }), null)<br/><br/>    storage_features = optional(object({<br/>      flash_mode = optional(object({<br/>        is_enabled = optional(bool, false)<br/>      }), null)<br/>    }), null)<br/><br/>    vm_attachments = optional(list(object({<br/>      vm_ext_id = string           # VM UUID<br/>      index     = optional(number) # SCSI bus index<br/>    })), [])<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_outputs"></a> [outputs](#output\_outputs) | Aggregate of all module outputs (spec §7.6 contract, consumed by the landing zone as module.<x>.outputs). |
| <a name="output_storage_container_ids"></a> [storage\_container\_ids](#output\_storage\_container\_ids) | Map of storage container keys to their external IDs. |
| <a name="output_storage_containers"></a> [storage\_containers](#output\_storage\_containers) | Map of created storage containers with their details. |
| <a name="output_storage_policies"></a> [storage\_policies](#output\_storage\_policies) | Map of created storage policies with their details. |
| <a name="output_storage_policy_ids"></a> [storage\_policy\_ids](#output\_storage\_policy\_ids) | Map of storage policy keys to their external IDs. |
| <a name="output_storage_summary"></a> [storage\_summary](#output\_storage\_summary) | Summary of storage resources managed by this module. |
| <a name="output_volume_group_category_associations"></a> [volume\_group\_category\_associations](#output\_volume\_group\_category\_associations) | Map of volume group category associations with their resolved VG ext\_id and categories. |
| <a name="output_volume_group_disk_ids"></a> [volume\_group\_disk\_ids](#output\_volume\_group\_disk\_ids) | Map of volume group disk keys to their external IDs. |
| <a name="output_volume_group_disks"></a> [volume\_group\_disks](#output\_volume\_group\_disks) | Map of created volume group disks with their details. |
| <a name="output_volume_group_ids"></a> [volume\_group\_ids](#output\_volume\_group\_ids) | Map of volume group keys to their external IDs. |
| <a name="output_volume_group_iscsi_client_ids"></a> [volume\_group\_iscsi\_client\_ids](#output\_volume\_group\_iscsi\_client\_ids) | Map of volume group iSCSI client keys to their external IDs. |
| <a name="output_volume_group_iscsi_clients"></a> [volume\_group\_iscsi\_clients](#output\_volume\_group\_iscsi\_clients) | Map of volume group iSCSI clients with their details (no secrets). |
| <a name="output_volume_group_vm_attachments"></a> [volume\_group\_vm\_attachments](#output\_volume\_group\_vm\_attachments) | Map of volume group VM attachments with their details. |
| <a name="output_volume_groups"></a> [volume\_groups](#output\_volume\_groups) | Map of created volume groups with their details. |
<!-- END_TF_DOCS -->

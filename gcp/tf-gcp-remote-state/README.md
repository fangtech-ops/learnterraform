<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp-bucket"></a> [gcp-bucket](#module\_gcp-bucket) | terraform-google-modules/cloud-storage/google | ~> 2.2 |
| <a name="module_kms-key"></a> [kms-key](#module\_kms-key) | terraform-google-modules/kms/google | ~> 2.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Destroy the bucket even if it's not empty | `bool` | `false` | no |
| <a name="input_keyring"></a> [keyring](#input\_keyring) | The keyring to use for encryption | `string` | n/a | yes |
| <a name="input_keys"></a> [keys](#input\_keys) | The keys to create | `list(any)` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | The labels of the bucket | `map(string)` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of the bucket | `string` | n/a | yes |
| <a name="input_names"></a> [names](#input\_names) | The name of the bucket to create | `list(any)` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | The owners of the bucket | `list(any)` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to use for the bucket | `string` | n/a | yes |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | The storage class of the bucket | `string` | `"STANDARD"` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Enable versioning on the bucket | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | n/a |
<!-- END_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.13.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_narvar-gcp-kms"></a> [narvar-gcp-kms](#module\_narvar-gcp-kms) | terraform-google-modules/kms/google | 2.1.0 |

## Resources

| Name | Type |
|------|------|
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_rotation_period"></a> [key\_rotation\_period](#input\_key\_rotation\_period) | The key rotation period | `string` | `"604800s"` | no |
| <a name="input_keyring"></a> [keyring](#input\_keyring) | The keyring to use | `string` | n/a | yes |
| <a name="input_keys"></a> [keys](#input\_keys) | Keys to create | `list(string)` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the keys | `map(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location to use | `string` | n/a | yes |
| <a name="input_prevent_destroy"></a> [prevent\_destroy](#input\_prevent\_destroy) | Whether to prevent destroy | `bool` | `true` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud project ID to use | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
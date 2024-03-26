
# tf-gcp-dns
wraps : https://github.com/terraform-google-modules/terraform-google-cloud-dns

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns-zone"></a> [dns-zone](#module\_dns-zone) | terraform-google-modules/cloud-dns/google | 4.1.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dnssec_state"></a> [dnssec\_state](#input\_dnssec\_state) | Turn on DNSSEC for the zone | `map(string)` | <pre>{<br>  "state": "on"<br>}</pre> | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain value | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the DNS Zone | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_stack"></a> [stack](#input\_stack) | Stack value | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | Type of zone to create, valid values are 'public', 'private', 'forwarding', 'peering' | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Name of Domain |
| <a name="output_name"></a> [name](#output\_name) | Name of the DNS zone |
| <a name="output_name_servers"></a> [name\_servers](#output\_name\_servers) | List of Name Servers |
| <a name="output_type"></a> [type](#output\_type) | Type of DNS Domain |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

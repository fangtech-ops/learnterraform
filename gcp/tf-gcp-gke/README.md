# terraform gke module


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_container_cluster.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the cluster | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | (optional) describe your variable | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | (optional) describe your variable | `string` | n/a | yes |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | (optional) describe your variable | `number` | n/a | yes |
| <a name="input_node_locations"></a> [node\_locations](#input\_node\_locations) | Locations of the nodes | `list` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project ID for this cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | The client certificate of the cluster |
| <a name="output_client_key"></a> [client\_key](#output\_client\_key) | The client key of the cluster |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the cluster |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The endpoint of the cluster |
| <a name="output_master_version"></a> [master\_version](#output\_master\_version) | The version of the API server |
<!-- END_TF_DOCS -->

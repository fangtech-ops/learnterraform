
# tf-gcp-workload-identity

Narvar TF Module for creating a [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/concepts/workload-identity)

Wraps [official module](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest/submodules/workload-identity)


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_workload-identity"></a> [workload-identity](#module\_workload-identity) | terraform-google-modules/kubernetes-engine/google//modules/workload-identity | 20.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name. Required if using existing KSA. | `string` | n/a | yes |
| <a name="input_gcp_sa_name"></a> [gcp\_sa\_name](#input\_gcp\_sa\_name) | Name for the Google service account | `string` | n/a | yes |
| <a name="input_k8s_sa_name"></a> [k8s\_sa\_name](#input\_k8s\_sa\_name) | Name for the Kubernetes service account | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Cluster location (region if regional cluster, zone if zonal cluster). Required if using existing KSA. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Kubernetes service account | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_roles"></a> [roles](#input\_roles) | A list of roles to be added to the created service account | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gcp_service_account"></a> [gcp\_service\_account](#output\_gcp\_service\_account) | GCP service account. |
| <a name="output_gcp_service_account_email"></a> [gcp\_service\_account\_email](#output\_gcp\_service\_account\_email) | Email address of GCP service account. |
| <a name="output_gcp_service_account_fqn"></a> [gcp\_service\_account\_fqn](#output\_gcp\_service\_account\_fqn) | FQN of GCP service account. |
| <a name="output_gcp_service_account_name"></a> [gcp\_service\_account\_name](#output\_gcp\_service\_account\_name) | Name of GCP service account. |
| <a name="output_k8s_service_account_name"></a> [k8s\_service\_account\_name](#output\_k8s\_service\_account\_name) | Name of k8s service account. |
| <a name="output_k8s_service_account_namespace"></a> [k8s\_service\_account\_namespace](#output\_k8s\_service\_account\_namespace) | Namespace of k8s service account. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

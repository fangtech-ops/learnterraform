resource "github_repository_file" "cm" { # https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file
  repository          = "flux-infra"
  branch              = "master"
  file                = var.terraform_configuraton_file
  commit_message      = var.github_repository_file_cm_commit_message
  commit_author       = "Narvar terraform user from Github repo terraform-aws-accounts"
  commit_email        = "terraform@narvar.com"
  overwrite_on_create = true

  content = templatefile(
    "${path.module}/files/templates/configmap.tpl",
    {
      aws_region = var.aws_region
      # aws_nats                        = join(",", data.terraform_remote_state.vpc.outputs.nat_public_ips)
      # aws_private_subnets             = join(",", data.terraform_remote_state.vpc.outputs.private_subnet_ids)
      # aws_public_subnets              = join(",", data.terraform_remote_state.vpc.outputs.public_subnet_ids)

      # The outer pair of braces "{}" is Helm's syntax to denote a list (i.e., array). See:
      #     - https://fluxcd.io/docs/components/helm/helmreleases/#values-overrides
      #     - https://helm.sh/docs/intro/using_helm/#the-format-and-limitations-of---set
      # Although Route53 has a 1-to-1 mapping between Zone ID and DNS domain name, cert-manager's "kind: ClusterIssuer" for some reason
      # accepts a list of DNS domain names for the attribute '.spec.acme.solvers.dns01.selector.dnsZones'.
      route53_public_hosted_zone1_domain_name_list = "{${data.terraform_remote_state.networking_infra.outputs.domain_name_devops_narvarcorp_net}}"
      route53_public_hosted_zone1_id               = data.terraform_remote_state.networking_infra.outputs.zone_id_devops_narvarcorp_net

      irsa_atlantis_role_arn           = module.narvar-irsa-role-for-atlantis.iam_role_arn
      irsa_cert_manager_role_arn       = data.terraform_remote_state.networking_irsa.outputs.narvar-irsa-role-for-cert-manager-eks-devops-iam_role_arn
      irsa_external_dns_role_arn       = data.terraform_remote_state.networking_irsa.outputs.narvar-irsa-role-for-external-dns-eks-devops-iam_role_arn
      irsa_cluster_autoscaler_role_arn = module.narvar-irsa-role-for-cluster-autoscaler.iam_role_arn
      irsa_external_secrets_role_arn   = module.narvar-irsa-role-for-external-secrets.iam_role_arn

      eks_cluster_name = local.cluster_name
      # eks_cluster_version             = var.cluster_version
    }
  )
}

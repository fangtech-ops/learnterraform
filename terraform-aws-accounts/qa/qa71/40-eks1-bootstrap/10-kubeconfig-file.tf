#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = local.cluster_id
      cluster = {
        certificate-authority-data = data.aws_eks_cluster.eks1.certificate_authority[0].data
        server                     = data.aws_eks_cluster.eks1.endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = local.cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        exec = {
          apiVersion = "client.authentication.k8s.io/v1alpha1"
          command    = "aws"
          args = [
            "eks", "get-token",
            "--cluster-name", "${local.cluster_name}",
            "--region", "${var.aws_region}",
            "--role-arn", "${var.narvar_terraform_role_arn}"
          ]
        }
      }
    }]
  })
}

resource "local_file" "kubeconfig" {
  content              = local.kubeconfig
  filename             = local.kubeconfig_filename
  file_permission      = "0600"
  directory_permission = "0755"
}

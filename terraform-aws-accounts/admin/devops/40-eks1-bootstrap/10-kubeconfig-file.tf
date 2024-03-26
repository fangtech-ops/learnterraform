# Purpose: Create a kubeconfig file to be used by various *.tf (local-exec) in this folder.
# 
# Normally, each engineer to manually run the following command to generate his own ~/.kube/config on his lapotp.
#       $ aws eks update-kubeconfig ...
#
# That would work *later* after our Flux (via the 'flux bootstrap ...' in this folder) has set up 
# the 'aws-auth' ConfigMap properly. But before that (as the moment we're in now), the above usual command 
# wouldn't be enough. Instead, we'd need to add an extra param.
# Using 'eks-dev71' as an example, the (hypothetical) command would have been:
#       $ aws eks update-kubeconfig --name eks-dev71 --role-arn arn:aws:iam::342812538696:role/NarvarTerraformRole
#
# That's because, right after an EKS cluster is created (i.e., right after 30-eks1 folder is applied 
# but before this 40-eks1-bootstrap folder is applied), only the EKS cluster's owner (i.e., NarvarTerraformRole)
# has access to it. 
#
# That's why in the above hypothetical command, we'd have had to add '--role-arn' (the value goes into ~/.kube/config).
# But that would be too strange a way to handle things -- and even then, it would have been only for a temporary measure.
# After this 40-eks1-bootstrap folder is applied, our Flux would have added more IAM roles to the 'aws-auth' ConfigMap 
# so that '--role-arn' won't be necessary anymore.
#
# So, to avoid all the strangeness discussed above, we generate a (temporary) kubeconfig file used only during 'terraform apply'
# in this 40-eks1-bootstrap folder.
#
# This *.tf code is modeled after:
#   - https://github.com/terraform-aws-modules/terraform-aws-eks/blob/9f85dc8cf5028ed2bab49f495f58e68aa870e7d4/examples/eks_managed_node_group/main.tf#L299-L325
#   - https://github.com/terraform-aws-modules/terraform-aws-eks/blob/3002be59ef25e67bc4dfc9a1d196174aeb871d8b/kubectl.tf
#   - https://github.com/narvar/terraform-aws-accounts/blob/107c8ec1d50ba312a6361136b8f3b2435afe41be/dev/dev71/30-eks1/eks.tf#L67-L72

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
        # We choose not to do the following which is a secret:
        #   token = data.aws_eks_cluster_auth.eks1.token
        # Instead, we do the following which contains no secret (therefore safe to be committed to Github)
        # and which more clearly demonstrates the intent and reason for '--role-arn' as explained 
        # in comments at the top of this *.tf.
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

resource "local_file" "kubeconfig" { # https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
  content              = local.kubeconfig
  filename             = local.kubeconfig_filename
  file_permission      = "0600"
  directory_permission = "0755"
}

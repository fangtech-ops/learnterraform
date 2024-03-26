# This script is obsolete.
# See comments in ./files/scripts/create_atlantis_secrets.sh



# locals {
#   # Note: The secret name (or Kubernetes resource names in general) must be in lower case.
#   atlantis_vcsSecretName       = "atlantis-vcs-secret-for-github-webhook"
#   atlantis_gitconfigSecretName = "atlantis-gitconfig-for-fetching-terraform-private-modules"
# }

# resource "null_resource" "atlantis-secret" {
#   depends_on = [
#     local_file.kubeconfig,
#   ]

#   triggers = {
#     hash = filesha256("${local.scripts_dir}/create_atlantis_secrets.sh") # Triggered if the file content has changed.
#     # always_run = "${timestamp()}"

#     # For why we assign the following triggers, see their references and comments below.
#     scripts_dir                  = local.scripts_dir
#     kubeconfig_filename          = local.kubeconfig_filename
#     atlantis_vcsSecretName       = local.atlantis_vcsSecretName
#     atlantis_gitconfigSecretName = local.atlantis_gitconfigSecretName

#     # Do NOT put var.github_token or var.github_atlantis_webhook_secret as a trigger. If we did, those secrets
#     # would be saved into terraform.tfstate in cleartext.
#     # TODO:
#     #   - What if the secrets changed? Need to test and document the solution.
#   }

#   provisioner "local-exec" {
#     command = "${local.scripts_dir}/create_atlantis_secrets.sh ${local.atlantis_vcsSecretName} ${self.triggers.atlantis_gitconfigSecretName}"

#     environment = {
#       KUBECONFIG                     = local.kubeconfig_filename
#       GITHUB_TOKEN                   = var.github_token                   # Tip: Pass in this value via env var TF_VAR_github_token
#       GITHUB_ATLANTIS_WEBHOOK_SECRET = var.github_atlantis_webhook_secret # Tip: Pass in this value via env var TF_VAR_github_atlantis_webhook_secret
#     }

#     interpreter = ["/bin/bash", "-c"]
#   }

#   provisioner "local-exec" {
#     when = destroy

#     # Ideally, we'd like to reference local vars or input vars in the next few lines, but terraform doesn't allow it:
#     #   │ Error: Invalid reference from destroy provisioner
#     #   │ Destroy-time provisioners and their connection configurations may only reference attributes of the related resource, via 'self', 'count.index', or 'each.key'.
#     #   │ References to other resources during the destroy phase can cause dependency cycles and interact poorly with create_before_destroy.
#     #
#     # That's why we assigned various vars to 'triggers' above -- in order to be able to reference them here.
#     command = "${self.triggers.scripts_dir}/delete_atlantis_secrets.sh ${self.triggers.atlantis_vcsSecretName} ${self.triggers.atlantis_gitconfigSecretName}"

#     environment = {
#       KUBECONFIG = self.triggers.kubeconfig_filename
#     }

#     interpreter = ["/bin/bash", "-c"]
#   }
# }

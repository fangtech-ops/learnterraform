#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

resource "null_resource" "flux-bootstrap" {

  depends_on = [
    github_repository_file.cm,
    local_file.kubeconfig,
  ]

  triggers = {
    hash = filesha256("${local.scripts_dir}/flux.sh")
    # always_run = "${timestamp()}"

    kubeconfig_filename = local.kubeconfig_filename
  }

  provisioner "local-exec" {
    command = "${local.scripts_dir}/flux.sh ${var.flux_bootstrap_params}"

    environment = {
      KUBECONFIG   = local.kubeconfig_filename
      GITHUB_USER  = var.github_user
      GITHUB_TOKEN = var.github_token
    }

    interpreter = ["/bin/bash", "-c"]
  }
}

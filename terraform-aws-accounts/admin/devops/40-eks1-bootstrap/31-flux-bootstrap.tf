resource "null_resource" "flux-bootstrap" {

  depends_on = [
    github_repository_file.cm,
    local_file.kubeconfig,
  ]

  triggers = {
    hash = filesha256("${local.scripts_dir}/flux.sh") # Triggered if the file content has changed.
    # always_run = "${timestamp()}"

    # See ./20-atlantis-secret.tf for explanation of the following trigger attributes.
    kubeconfig_filename = local.kubeconfig_filename

    # Do NOT put var.github_token as a trigger. If we did, that secret would be saved into terraform.tfstate in cleartext.
    # TODO:
    #   - What if var.github_token (or var.github_user) changed? Need to test and document the solution (do we force a 'flux boostrap' again?)
  }

  provisioner "local-exec" {
    command = "${local.scripts_dir}/flux.sh ${var.flux_bootstrap_params}"

    environment = {
      KUBECONFIG   = local.kubeconfig_filename
      GITHUB_USER  = var.github_user  # Tip: Pass in this value via env var TF_VAR_github_user
      GITHUB_TOKEN = var.github_token # Tip: Pass in this value via env var TF_VAR_github_token
    }

    interpreter = ["/bin/bash", "-c"]
  }


  # # We comment this block out for now. Reasons:
  # #   - 'flux bootstrap ...' is idempotent. It often isn't important for 'terraform apply' to trigger 'flux uninstall'
  # #      whenever terraform thinks it needs to re-run the above 'local-exec'.
  # #   - 'flux uninstall' is too dramatic if all we have changed is a line of comment in the script ${local.scripts_dir}/flux.sh.
  # #   - If we really want to uninstall flux, we can easily run the command 'flux uninstall' manually ourselves.
  #
  # provisioner "local-exec" {
  #   when    = destroy
  #   command = "flux uninstall -s"
  #   environment = {
  #     KUBECONFIG = self.triggers.kubeconfig_filename
  #   }
  #   interpreter = ["/bin/bash", "-c"]
  # }
}

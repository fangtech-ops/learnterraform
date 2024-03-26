See [/admin/devops/30-eks/README.md](https://github.com/narvar/terraform-aws-accounts/tree/main/admin/devops/30-eks1/README.md).

This `qa71` stack is in the old QA account, not under the new AWS Control Tower / SSO. So, the way to launch terraform in this folder is a bit different. We need to do:

```console
  ## On laptop
  ## Launch the Docker container https://github.com/narvar/foundation-local-env
$ nt

  ## Now we're inside the Docker container.
  ## Use the alias 'mfaqa' rather than 'sso'.
  ## Only need to do it once per 24 hours (across all current and future containers).
# mfaqa

  ## Switch env.
# qa71

# cd /GITHUB/terraform-aws-accounts/qa/qa71/30-eks1
# tf apply
```

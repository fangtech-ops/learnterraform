#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

variable "aws_region" {
  default = "us-west-2"
}

variable "narvar_terraform_role_arn" {
  default = "arn:aws:iam::472882997329:role/NarvarTerraformRole"
}

variable "vpc1-name" {
  default = "vpc-qa71"
}

variable "vpc1-cidr" {
  description = "10.181.[0-127].* (32,768 IPs), see https://narvar.atlassian.net/wiki/spaces/devops/pages/122028114/VPC+CIDR"
  default     = "10.181.0.0/17"
}

variable "vpc1-private_subnets" {
  default = [
    "10.181.0.0/19",  # 10.181.[0-31].*   (8,192 IPs)
    "10.181.32.0/19", # 10.181.[32-63].*  (8,192 IPs)
    "10.181.64.0/19", # 10.181.[64-95].*  (8,192 IPs)
  ]
}

# Unused space between private and public subnets:
#   10.181.96.0-10.181.124.255  (7424 IPs = 4096 + 2048 + 1024 + 256)

variable "vpc1-public_subnets" {
  default = [
    "10.181.127.0/24", # 10.181.127.*     (256 IPs)
    "10.181.126.0/24", # 10.181.126.*     (256 IPs)
    "10.181.125.0/24", # 10.181.125.*     (256 IPs)
  ]
}

variable "jump-vpc-cidr" {
  default = "10.70.0.0/24"
}

variable "enable_aws_ebs_encryption_by_default" {
  # In the old QA account, this must be 'false' (at least for now) because:
  #   - https://narvar.slack.com/archives/C0ADRHE7Q/p1644015475056399?thread_ts=1644003332.039409&cid=C0ADRHE7Q
  #     For CircleCI error: https://app.circleci.com/pipelines/github/narvar/orders-api/951/workflows/08bd935c-1845-47de-ac36-82dfdc81fea0/jobs/4855
  # excerpt:
  #     Found the culprit:
  #     https://github.com/narvar/DevOps/blob/master/packer/orders_api.yml#L39-L41
  #     excerpt:
  #         # File: DevOps/packer/orders_api.yml
  #         ...
  #           ami_users:
  #           - '472882997329'
  #           - '533313119160'
  #     So, packer is trying to share this newly built custom AMI (built from the account represented by aws_access_key -- which is
  #     the QA account) to some foreign account(s). Because the newly built AMI is encrypted now, such sharing isn't allowed (directly).
  #     The Prod account never had this problem because Packer is never run (therefore custom AMIs are never built) inside Prod account.
  #     The AMI built in QA account is shared to the Prod account.
  #     P.S. Incidentally, this is probably the reason that this EBS encryption flag in QA has historically been flip-flop'ing
  #          several times during the past few years. Once in a while, someone thinks it's harmless to (manually) flip on this flag,
  #          only to be defeated by this AMI sharing thing, then had to revert.
  #          Had this been done in Terraform, an inline comment could have been written to stave off future attempts.

  default = false
}

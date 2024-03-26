provider "aws" {
  region = "us-west-2"
  access_key = "AKIAT6TFF2NPQFPHJ4V2"
  secret_key = "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"
}

data "packet_project" "mkdev" {
  name = var.project_name
}

module "production-cluster" {
  source = "./modules/k3s-cluster"
  environment = "prod"
  project_id = data.packet_project.mkdev.id
}


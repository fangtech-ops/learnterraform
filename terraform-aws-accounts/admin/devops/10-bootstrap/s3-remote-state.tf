module "remote-state-infra" {
  source       = "git@github.com:narvar/tf-remote-state.git//aws?ref=0.0.2"
  aws_account  = local.account_id
  aws_region   = var.aws_region
  environment  = var.environment
  project_name = var.project_name
}

output "infra_bucket_id" {
  value = module.remote-state-infra.state_bucket_id
}

output "infra_dynamodb_table_id" {
  value = module.remote-state-infra.dynamodb_table_id
}

provider "google" {
  version = "4.1.1"
  credentials = file("<NAME>.json")
  project = var.project_id
  region  = var.location
  zone    = var.zone
}

/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/******************************************
	VPC configuration
 *****************************************/
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 4.0"
  network_name                           = var.network_name
  auto_create_subnetworks                = var.auto_create_subnetworks
  routing_mode                           = var.routing_mode
  project_id                             = var.project_id
  mtu                                    = var.mtu
}



/******************************************
	Firewall rules
 *****************************************/
locals {
  rules = [
    {
      name                    = "monitor-base-us-allow-ssh-ingress"
      direction               = "INGRESS"
      priority                = lookup(f, "priority", 1000)
      description             = null
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow                   = [{
                                  protocal  = "tcp"
                                  ports     = ["22"]
                                }]
      deny                    = []
      log_config              = {
                                 metadata "INCLUDE_ALL_METADATA"
                                }
    }
    {
    name                    = "monitor-base-us-allow-http-ingress"
    direction               = "INGRESS"
    priority                = lookup(f, "priority", 1000)
    description             = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow                   = [{
                                protocal  = "tcp"
                                ports     = ["80"]
                              }]
    deny                    = []
    log_config              = {
                               metadata "INCLUDE_ALL_METADATA"
                              }
    }
    {
    name                    = "monitor-base-us-allow-https-ingress"
    direction               = "INGRESS"
    priority                = lookup(f, "priority", 1000)
    description             = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow                   = [{
                                protocal  = "tcp"
                                ports     = ["443"]
                              }]
    deny                    = []
    log_config              = {
                               metadata "INCLUDE_ALL_METADATA"
                              }
    }

  ]
}

module "firewall_rules" {
  source       = "./modules/firewall-rules"
  project_id   = var.project_id
  network_name = module.vpc.network_name
  rules        = local.rules
}

output "domain_name" {
  description = "Name of Domain"
  value       = module.dns-zone.domain
}

output "name" {
  description = "Name of the DNS zone"
  value       = module.dns-zone.name
}

output "name_servers" {
  description = "List of Name Servers"
  value       = module.dns-zone.name_servers
}

output "type" {
  description = "Type of DNS Domain"
  value       = module.dns-zone.type
}

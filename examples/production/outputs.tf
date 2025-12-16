output "user_pool_id" {
  description = "The ID of the user pool"
  value       = module.cognito.id
}

output "user_pool_arn" {
  description = "The ARN of the user pool"
  value       = module.cognito.arn
}

output "client_ids_map" {
  description = "Map of app client names to IDs"
  value       = module.cognito.client_ids_map
}

output "user_group_names_map" {
  description = "Map of user group keys to their names"
  value       = module.cognito.user_group_names_list
}

output "domain" {
  description = "The domain for the user pool"
  value       = module.cognito.domain
}

output "hosted_ui_url" {
  description = "The hosted UI URL"
  value       = module.cognito.domain != null ? "https://${module.cognito.domain}.auth.${data.aws_region.current.id}.amazoncognito.com" : null
}

data "aws_region" "current" {}

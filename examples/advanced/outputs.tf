output "user_pool_id" {
  description = "The ID of the user pool"
  value       = module.cognito.id
}

output "user_pool_arn" {
  description = "The ARN of the user pool"
  value       = module.cognito.arn
}

output "client_ids" {
  description = "Map of app client names to IDs"
  value       = module.cognito.client_ids
}

output "client_secrets" {
  description = "Map of app client names to secrets (sensitive)"
  value       = module.cognito.client_secrets
  sensitive   = true
}

output "resource_server_identifiers" {
  description = "List of resource server identifiers"
  value       = module.cognito.resource_server_identifiers
}

output "resource_server_scope_identifiers" {
  description = "Map of resource server identifiers to scope identifiers"
  value       = module.cognito.resource_server_scope_identifiers
}

output "hosted_ui_url" {
  description = "The hosted UI URL"
  value       = module.cognito.domain != null ? "https://${module.cognito.domain}.auth.${data.aws_region.current.id}.amazoncognito.com" : null
}

output "oauth_authorize_url" {
  description = "OAuth authorization URL"
  value       = module.cognito.domain != null ? "https://${module.cognito.domain}.auth.${data.aws_region.current.id}.amazoncognito.com/oauth2/authorize" : null
}

output "oauth_token_url" {
  description = "OAuth token URL"
  value       = module.cognito.domain != null ? "https://${module.cognito.domain}.auth.${data.aws_region.current.id}.amazoncognito.com/oauth2/token" : null
}

data "aws_region" "current" {}

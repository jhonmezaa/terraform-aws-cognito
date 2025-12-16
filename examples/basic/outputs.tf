output "user_pool_id" {
  description = "The ID of the user pool"
  value       = module.cognito.id
}

output "user_pool_arn" {
  description = "The ARN of the user pool"
  value       = module.cognito.arn
}

output "user_pool_endpoint" {
  description = "The endpoint name of the user pool"
  value       = module.cognito.endpoint
}

output "client_ids" {
  description = "Map of app client names to IDs"
  value       = module.cognito.client_ids
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

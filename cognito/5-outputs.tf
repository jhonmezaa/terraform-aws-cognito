# User Pool Outputs
output "id" {
  description = "The ID of the user pool"
  value       = aws_cognito_user_pool.this.id
}

output "arn" {
  description = "The ARN of the user pool"
  value       = aws_cognito_user_pool.this.arn
}

output "name" {
  description = "The name of the user pool"
  value       = aws_cognito_user_pool.this.name
}

output "endpoint" {
  description = "The endpoint name of the user pool"
  value       = aws_cognito_user_pool.this.endpoint
}

output "creation_date" {
  description = "The date the user pool was created"
  value       = aws_cognito_user_pool.this.creation_date
}

output "last_modified_date" {
  description = "The date the user pool was last modified"
  value       = aws_cognito_user_pool.this.last_modified_date
}

output "custom_domain" {
  description = "The custom domain name for the user pool"
  value       = aws_cognito_user_pool.this.custom_domain
}

output "estimated_number_of_users" {
  description = "A number estimating the size of the user pool"
  value       = aws_cognito_user_pool.this.estimated_number_of_users
}

output "user_pool_tier" {
  description = "The tier of the user pool (LITE, ESSENTIALS, or PLUS)"
  value       = aws_cognito_user_pool.this.user_pool_tier
}

# App Client Outputs
output "client_ids" {
  description = "The IDs of the user pool clients"
  value       = { for k, v in aws_cognito_user_pool_client.this : k => v.id }
}

output "client_secrets" {
  description = "The client secrets of the user pool clients (sensitive)"
  value       = { for k, v in aws_cognito_user_pool_client.this : k => v.client_secret }
  sensitive   = true
}

# Domain Outputs
output "domain" {
  description = "The domain name for the user pool"
  value       = var.domain != null ? aws_cognito_user_pool_domain.this[0].domain : null
}

output "domain_aws_account_id" {
  description = "The AWS account ID for the user pool domain"
  value       = var.domain != null ? aws_cognito_user_pool_domain.this[0].aws_account_id : null
}

output "domain_cloudfront_distribution" {
  description = "The CloudFront distribution ARN for the domain"
  value       = var.domain != null ? aws_cognito_user_pool_domain.this[0].cloudfront_distribution : null
}

output "domain_cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution for the domain"
  value       = var.domain != null ? aws_cognito_user_pool_domain.this[0].cloudfront_distribution_arn : null
}

output "domain_cloudfront_distribution_zone_id" {
  description = "The CloudFront distribution zone ID for the domain (for Route53 alias records)"
  value       = var.domain != null ? aws_cognito_user_pool_domain.this[0].cloudfront_distribution_zone_id : null
}

output "domain_s3_bucket" {
  description = "The S3 bucket where the static files for the domain are stored"
  value       = var.domain != null ? aws_cognito_user_pool_domain.this[0].s3_bucket : null
}

output "domain_version" {
  description = "The app version for the domain"
  value       = var.domain != null ? aws_cognito_user_pool_domain.this[0].version : null
}

# Custom Domain Outputs
output "custom_domain_name" {
  description = "The custom domain name"
  value       = var.custom_domain != null ? aws_cognito_user_pool_domain.custom[0].domain : null
}

output "custom_domain_cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution for the custom domain"
  value       = var.custom_domain != null ? aws_cognito_user_pool_domain.custom[0].cloudfront_distribution_arn : null
}

# User Group Outputs
output "user_group_names" {
  description = "List of user group names"
  value       = [for g in aws_cognito_user_group.this : g.name]
}

output "user_group_names_list" {
  description = "Map of user group names to their full name"
  value       = { for k, v in aws_cognito_user_group.this : k => v.name }
}

output "user_group_ids" {
  description = "Map of user group keys to their IDs"
  value       = { for k, v in aws_cognito_user_group.this : k => v.id }
}

output "user_groups_map" {
  description = "Complete map of user groups with all attributes"
  value = {
    for k, v in aws_cognito_user_group.this : k => {
      id          = v.id
      name        = v.name
      description = v.description
      precedence  = v.precedence
      role_arn    = v.role_arn
    }
  }
}

# Identity Provider Outputs
output "identity_provider_names" {
  description = "List of identity provider names"
  value       = [for idp in aws_cognito_identity_provider.this : idp.provider_name]
}

# Resource Server Outputs
output "resource_server_ids" {
  description = "Map of resource server identifiers to their IDs"
  value       = { for k, v in aws_cognito_resource_server.this : k => v.id }
}

output "resource_server_identifiers" {
  description = "List of resource server identifiers"
  value       = [for rs in aws_cognito_resource_server.this : rs.identifier]
}

output "resource_server_scope_identifiers" {
  description = "Map of resource server identifiers to their scope identifiers"
  value = {
    for k, rs in aws_cognito_resource_server.this : k => [
      for scope in rs.scope : "${rs.identifier}/${scope.scope_name}"
    ]
  }
}

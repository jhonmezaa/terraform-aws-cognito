# Cognito User Groups
resource "aws_cognito_user_group" "this" {
  for_each = { for group in var.user_groups : group.name => group }

  name         = each.value.name
  user_pool_id = aws_cognito_user_pool.this.id
  description  = lookup(each.value, "description", null)
  precedence   = lookup(each.value, "precedence", null)
  role_arn     = lookup(each.value, "role_arn", null)
}

# Identity Providers
resource "aws_cognito_identity_provider" "this" {
  for_each = { for idp in var.identity_providers : idp.provider_name => idp }

  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = each.value.provider_name
  provider_type = each.value.provider_type

  provider_details = each.value.provider_details

  attribute_mapping = lookup(each.value, "attribute_mapping", null)

  idp_identifiers = lookup(each.value, "idp_identifiers", null)
}

# Resource Servers
resource "aws_cognito_resource_server" "this" {
  for_each = { for rs in var.resource_servers : rs.identifier => rs }

  identifier   = each.value.identifier
  name         = each.value.name
  user_pool_id = aws_cognito_user_pool.this.id

  dynamic "scope" {
    for_each = lookup(each.value, "scopes", [])
    content {
      scope_name        = scope.value.scope_name
      scope_description = scope.value.scope_description
    }
  }
}

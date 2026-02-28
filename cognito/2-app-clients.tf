# AWS Cognito User Pool Clients
resource "aws_cognito_user_pool_client" "this" {
  for_each = { for client in var.app_clients : client.name => client }

  name         = "${local.user_pool_name}-${each.value.name}"
  user_pool_id = aws_cognito_user_pool.this.id

  # Client Secret
  generate_secret = lookup(each.value, "generate_secret", false)

  # Token Validity
  refresh_token_validity = lookup(each.value, "refresh_token_validity", null) != null ? each.value.refresh_token_validity : 30
  access_token_validity  = lookup(each.value, "access_token_validity", null) != null ? each.value.access_token_validity : 60
  id_token_validity      = lookup(each.value, "id_token_validity", null) != null ? each.value.id_token_validity : 60

  # Token Validity Units (always set to prevent confusion)
  token_validity_units {
    access_token  = lookup(each.value, "token_validity_units", null) != null ? lookup(each.value.token_validity_units, "access_token", "minutes") : "minutes"
    id_token      = lookup(each.value, "token_validity_units", null) != null ? lookup(each.value.token_validity_units, "id_token", "minutes") : "minutes"
    refresh_token = lookup(each.value, "token_validity_units", null) != null ? lookup(each.value.token_validity_units, "refresh_token", "days") : "days"
  }

  # Read/Write Attributes
  read_attributes  = lookup(each.value, "read_attributes", null)
  write_attributes = lookup(each.value, "write_attributes", null)

  # Explicit Auth Flows
  explicit_auth_flows = lookup(each.value, "explicit_auth_flows", [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ])

  # Supported Identity Providers
  supported_identity_providers = lookup(each.value, "supported_identity_providers", ["COGNITO"])

  # Callback URLs
  callback_urls = lookup(each.value, "callback_urls", null)

  # Logout URLs
  logout_urls = lookup(each.value, "logout_urls", null)

  # Default Redirect URI
  default_redirect_uri = lookup(each.value, "default_redirect_uri", null)

  # Allowed OAuth Flows
  allowed_oauth_flows                  = lookup(each.value, "allowed_oauth_flows", null)
  allowed_oauth_flows_user_pool_client = lookup(each.value, "allowed_oauth_flows_user_pool_client", false)
  allowed_oauth_scopes                 = lookup(each.value, "allowed_oauth_scopes", null)

  # Analytics Configuration
  dynamic "analytics_configuration" {
    for_each = lookup(each.value, "analytics_configuration", null) != null ? [1] : []
    content {
      application_id   = lookup(each.value.analytics_configuration, "application_id", null)
      application_arn  = lookup(each.value.analytics_configuration, "application_arn", null)
      external_id      = lookup(each.value.analytics_configuration, "external_id", null)
      role_arn         = lookup(each.value.analytics_configuration, "role_arn", null)
      user_data_shared = lookup(each.value.analytics_configuration, "user_data_shared", null)
    }
  }

  # Prevent User Existence Errors
  prevent_user_existence_errors = lookup(each.value, "prevent_user_existence_errors", "ENABLED")

  # Enable Token Revocation
  enable_token_revocation = lookup(each.value, "enable_token_revocation", true)

  # Enable Propagate Additional User Context Data
  enable_propagate_additional_user_context_data = lookup(each.value, "enable_propagate_additional_user_context_data", false)

  # Auth Session Validity
  auth_session_validity = lookup(each.value, "auth_session_validity", 3)

  # Ensure resource servers are created before app clients (for custom scopes)
  depends_on = [aws_cognito_resource_server.this]
}

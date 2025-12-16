# Basic Cognito User Pool Example

module "cognito" {
  source = "../../cognito"

  account_name = var.account_name
  project_name = var.project_name
  environment  = var.environment

  # User Pool Tier
  user_pool_tier = "ESSENTIALS"

  # Username Configuration
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password Policy
  password_minimum_length    = 8
  password_require_lowercase = true
  password_require_uppercase = true
  password_require_numbers   = true
  password_require_symbols   = false

  # MFA Configuration
  mfa_configuration = "OPTIONAL"

  # App Clients
  app_clients = [
    {
      name                   = "web-app"
      generate_secret        = false
      refresh_token_validity = 30
      access_token_validity  = 60
      id_token_validity      = 60
      explicit_auth_flows = [
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_USER_PASSWORD_AUTH"
      ]
      prevent_user_existence_errors = "ENABLED"
      enable_token_revocation       = true
    }
  ]

  # Domain for Hosted UI
  domain = "${var.account_name}-${var.project_name}-auth"

  tags = {
    Example = "basic"
  }
}

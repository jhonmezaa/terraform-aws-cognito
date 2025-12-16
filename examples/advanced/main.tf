# Advanced Cognito User Pool Example with OAuth and Identity Providers

module "cognito" {
  source = "../../cognito"

  account_name = var.account_name
  project_name = var.project_name
  environment  = "production"

  # User Pool Tier
  user_pool_tier = "PLUS"

  # Username Configuration
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password Policy
  password_minimum_length    = 10
  password_require_lowercase = true
  password_require_uppercase = true
  password_require_numbers   = true
  password_require_symbols   = true

  # MFA Configuration
  mfa_configuration = "OPTIONAL"

  # Advanced Security
  enable_advanced_security = true
  advanced_security_mode   = "AUDIT"

  # App Clients with OAuth
  app_clients = [
    {
      name                   = "web-app"
      generate_secret        = true
      refresh_token_validity = 30
      access_token_validity  = 60
      id_token_validity      = 60
      explicit_auth_flows = [
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_CUSTOM_AUTH"
      ]
      supported_identity_providers = ["COGNITO", "Google"]
      callback_urls = [
        "https://myapp.example.com/callback",
        "http://localhost:3000/callback"
      ]
      logout_urls = [
        "https://myapp.example.com/logout",
        "http://localhost:3000/logout"
      ]
      default_redirect_uri                 = "https://myapp.example.com/callback"
      allowed_oauth_flows                  = ["code", "implicit"]
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes = [
        "email",
        "openid",
        "profile",
        "aws.cognito.signin.user.admin",
        "api/read",
        "api/write"
      ]
      prevent_user_existence_errors = "ENABLED"
      enable_token_revocation       = true
    }
  ]

  # Domain for Hosted UI
  domain = "${var.account_name}-${var.project_name}-auth"

  # Resource Servers (for custom OAuth scopes)
  resource_servers = [
    {
      identifier = "api"
      name       = "My API"
      scopes = [
        {
          scope_name        = "read"
          scope_description = "Read access to API"
        },
        {
          scope_name        = "write"
          scope_description = "Write access to API"
        },
        {
          scope_name        = "admin"
          scope_description = "Admin access to API"
        }
      ]
    }
  ]

  # Identity Providers (example - requires actual provider configuration)
  # Uncomment and configure when you have provider credentials
  # identity_providers = [
  #   {
  #     provider_name = "Google"
  #     provider_type = "Google"
  #     provider_details = {
  #       client_id        = "your-google-client-id"
  #       client_secret    = "your-google-client-secret"
  #       authorize_scopes = "email profile openid"
  #     }
  #     attribute_mapping = {
  #       email    = "email"
  #       username = "sub"
  #       name     = "name"
  #     }
  #   }
  # ]

  # User Groups
  user_groups = [
    {
      name        = "api-admins"
      description = "API Administrators"
      precedence  = 1
    },
    {
      name        = "api-users"
      description = "API Users with read/write access"
      precedence  = 10
    }
  ]

  # Custom Schemas
  schemas = [
    {
      name                = "company"
      attribute_data_type = "String"
      mutable             = true
      required            = false
      min_length          = 1
      max_length          = 100
    },
    {
      name                = "api_quota"
      attribute_data_type = "Number"
      mutable             = true
      required            = false
      min_value           = 0
      max_value           = 10000
    }
  ]

  tags = {
    Example = "advanced"
    OAuth   = "enabled"
  }
}

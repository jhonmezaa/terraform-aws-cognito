# Production Cognito User Pool Example with Advanced Security

module "cognito" {
  source = "../../cognito"

  account_name = var.account_name
  project_name = var.project_name
  environment  = "production"

  # User Pool Tier - PLUS for advanced features
  user_pool_tier = "PLUS"

  # Username Configuration
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  case_sensitive           = false

  # Password Policy - Strict
  password_minimum_length          = 12
  password_require_lowercase       = true
  password_require_uppercase       = true
  password_require_numbers         = true
  password_require_symbols         = true
  temporary_password_validity_days = 3

  # MFA Configuration - Required
  mfa_configuration = "ON"

  # Advanced Security - Enforced
  enable_advanced_security = true
  advanced_security_mode   = "ENFORCED"

  # Account Recovery
  recovery_mechanisms = [
    {
      name     = "verified_email"
      priority = 1
    },
    {
      name     = "verified_phone_number"
      priority = 2
    }
  ]

  # User Attribute Update Settings
  attributes_require_verification_before_update = ["email"]

  # Admin Create User Config
  admin_create_user_config_allow_admin_create_user_only = false
  admin_create_user_config_email_subject                = "Your temporary password for ${var.project_name}"
  admin_create_user_config_email_message                = "Your username is {username} and temporary password is {####}. Please sign in and change your password."

  # Deletion Protection
  deletion_protection = "ACTIVE"

  # App Clients
  app_clients = [
    {
      name                   = "web-app"
      generate_secret        = false
      refresh_token_validity = 30
      access_token_validity  = 60
      id_token_validity      = 60
      token_validity_units = {
        refresh_token = "days"
        access_token  = "minutes"
        id_token      = "minutes"
      }
      explicit_auth_flows = [
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH"
      ]
      prevent_user_existence_errors = "ENABLED"
      enable_token_revocation       = true
      auth_session_validity         = 3
    },
    {
      name                   = "mobile-app"
      generate_secret        = false
      refresh_token_validity = 30
      access_token_validity  = 60
      id_token_validity      = 60
      explicit_auth_flows = [
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH"
      ]
      prevent_user_existence_errors = "ENABLED"
      enable_token_revocation       = true
    }
  ]

  # Domain for Hosted UI
  domain = "${var.account_name}-${var.project_name}-auth"

  # User Groups
  user_groups = [
    {
      name        = "admins"
      description = "Administrator group"
      precedence  = 1
    },
    {
      name        = "users"
      description = "Regular users group"
      precedence  = 10
    },
    {
      name        = "readonly"
      description = "Read-only users group"
      precedence  = 20
    }
  ]

  # Custom Schemas
  schemas = [
    {
      name                = "department"
      attribute_data_type = "String"
      mutable             = true
      required            = false
      min_length          = 1
      max_length          = 50
    },
    {
      name                = "employee_id"
      attribute_data_type = "String"
      mutable             = false
      required            = false
      min_length          = 1
      max_length          = 20
    }
  ]

  tags = {
    Example    = "production"
    CostCenter = "engineering"
    Compliance = "required"
  }
}

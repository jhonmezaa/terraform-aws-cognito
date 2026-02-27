# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================

variable "account_name" {
  description = "Account name for resource naming (e.g., 'prod', 'dev', 'staging')"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming (e.g., 'myapp', 'api')"
  type        = string
}

# ==============================================================================
# GENERAL CONFIGURATION
# ==============================================================================

variable "region_prefix" {
  description = "Region prefix for naming. If null, auto-detected from current region"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name (e.g., 'production', 'development', 'staging')"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "user_pool_tags" {
  description = "Additional tags specific to the user pool"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# USER POOL CONFIGURATION
# ==============================================================================

variable "user_pool_tier" {
  description = "User pool tier: LITE, ESSENTIALS, or PLUS"
  type        = string
  default     = "ESSENTIALS"

  validation {
    condition     = contains(["LITE", "ESSENTIALS", "PLUS"], var.user_pool_tier)
    error_message = "User pool tier must be LITE, ESSENTIALS, or PLUS"
  }
}

variable "alias_attributes" {
  description = "Attributes supported as an alias for this user pool (email, phone_number, preferred_username)"
  type        = list(string)
  default     = null
}

variable "username_attributes" {
  description = "Whether email addresses or phone numbers can be specified as usernames when a user signs up"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for attr in var.username_attributes : contains(["email", "phone_number"], attr)
    ])
    error_message = "Username attributes must be 'email' or 'phone_number'"
  }
}

variable "auto_verified_attributes" {
  description = "Attributes to be auto-verified (email, phone_number)"
  type        = list(string)
  default     = ["email"]

  validation {
    condition = alltrue([
      for attr in var.auto_verified_attributes : contains(["email", "phone_number"], attr)
    ])
    error_message = "Auto-verified attributes must be 'email' or 'phone_number'"
  }
}

variable "case_sensitive" {
  description = "Whether username case sensitivity will be applied for all users in the user pool"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "When active, prevents accidental deletion of your user pool"
  type        = string
  default     = "ACTIVE"

  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.deletion_protection)
    error_message = "Deletion protection must be ACTIVE or INACTIVE"
  }
}

# ==============================================================================
# MFA CONFIGURATION
# ==============================================================================

variable "mfa_configuration" {
  description = "Multi-factor authentication configuration: OFF, ON, or OPTIONAL"
  type        = string
  default     = "OPTIONAL"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be OFF, ON, or OPTIONAL"
  }
}

# ==============================================================================
# PASSWORD POLICY
# ==============================================================================

variable "password_minimum_length" {
  description = "Minimum length of the password policy"
  type        = number
  default     = 8

  validation {
    condition     = var.password_minimum_length >= 6 && var.password_minimum_length <= 99
    error_message = "Password minimum length must be between 6 and 99"
  }
}

variable "password_require_lowercase" {
  description = "Whether to require lowercase characters in passwords"
  type        = bool
  default     = true
}

variable "password_require_uppercase" {
  description = "Whether to require uppercase characters in passwords"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Whether to require numbers in passwords"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Whether to require symbols in passwords"
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "Number of days a temporary password is valid"
  type        = number
  default     = 7

  validation {
    condition     = var.temporary_password_validity_days >= 1 && var.temporary_password_validity_days <= 365
    error_message = "Temporary password validity must be between 1 and 365 days"
  }
}

# ==============================================================================
# SIGN-IN POLICY
# ==============================================================================

variable "sign_in_policy_allowed_first_auth_factors" {
  description = "List of allowed first authentication factors (PASSWORD, WEB_AUTHN, EMAIL_OTP, SMS_OTP)"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for factor in var.sign_in_policy_allowed_first_auth_factors :
      contains(["PASSWORD", "WEB_AUTHN", "EMAIL_OTP", "SMS_OTP"], factor)
    ])
    error_message = "Allowed factors must be PASSWORD, WEB_AUTHN, EMAIL_OTP, or SMS_OTP"
  }
}

# ==============================================================================
# USER ATTRIBUTE UPDATE SETTINGS
# ==============================================================================

variable "attributes_require_verification_before_update" {
  description = "Attributes that require verification before update (email, phone_number)"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for attr in var.attributes_require_verification_before_update :
      contains(["email", "phone_number"], attr)
    ])
    error_message = "Attributes must be 'email' or 'phone_number'"
  }
}

# ==============================================================================
# ACCOUNT RECOVERY
# ==============================================================================

variable "recovery_mechanisms" {
  description = "List of account recovery options"
  type = list(object({
    name     = string
    priority = number
  }))
  default = [
    {
      name     = "verified_email"
      priority = 1
    }
  ]

  validation {
    condition = alltrue([
      for mech in var.recovery_mechanisms :
      contains(["verified_email", "verified_phone_number", "admin_only"], mech.name)
    ])
    error_message = "Recovery mechanism names must be verified_email, verified_phone_number, or admin_only"
  }
}

# ==============================================================================
# ADMIN CREATE USER CONFIG
# ==============================================================================

variable "admin_create_user_config_allow_admin_create_user_only" {
  description = "Set to true if only the administrator is allowed to create user profiles"
  type        = bool
  default     = false
}

variable "admin_create_user_config_email_message" {
  description = "Message template for email messages"
  type        = string
  default     = null
}

variable "admin_create_user_config_email_subject" {
  description = "Subject line for email messages"
  type        = string
  default     = null
}

variable "admin_create_user_config_sms_message" {
  description = "Message template for SMS messages"
  type        = string
  default     = null
}

# ==============================================================================
# DEVICE CONFIGURATION
# ==============================================================================

variable "device_configuration_challenge_required_on_new_device" {
  description = "Whether a challenge is required on a new device"
  type        = bool
  default     = null
}

variable "device_configuration_device_only_remembered_on_user_prompt" {
  description = "Whether a device is only remembered on user prompt"
  type        = bool
  default     = null
}

# ==============================================================================
# EMAIL CONFIGURATION
# ==============================================================================

variable "email_configuration_source_arn" {
  description = "ARN of the SES verified email identity to use for sending emails"
  type        = string
  default     = null
}

variable "email_configuration_from_email_address" {
  description = "Email address to send emails from"
  type        = string
  default     = null
}

variable "email_configuration_reply_to_email_address" {
  description = "Reply-to email address"
  type        = string
  default     = null
}

variable "email_configuration_email_sending_account" {
  description = "Email sending account type: COGNITO_DEFAULT or DEVELOPER"
  type        = string
  default     = "COGNITO_DEFAULT"

  validation {
    condition     = var.email_configuration_email_sending_account == null || contains(["COGNITO_DEFAULT", "DEVELOPER"], var.email_configuration_email_sending_account)
    error_message = "Email sending account must be COGNITO_DEFAULT or DEVELOPER"
  }
}

variable "email_configuration_configuration_set" {
  description = "SES configuration set name"
  type        = string
  default     = null
}

# ==============================================================================
# SMS CONFIGURATION
# ==============================================================================

variable "sms_configuration_external_id" {
  description = "External ID used in IAM role trust policy"
  type        = string
  default     = null
}

variable "sms_configuration_sns_caller_arn" {
  description = "ARN of the IAM role that allows Cognito to send SMS messages"
  type        = string
  default     = null
}

variable "sms_configuration_sns_region" {
  description = "AWS Region to use for SNS (if different from current region)"
  type        = string
  default     = null
}

# ==============================================================================
# LAMBDA TRIGGERS
# ==============================================================================

variable "lambda_config_create_auth_challenge" {
  description = "ARN of the Lambda creating an authentication challenge"
  type        = string
  default     = null
}

variable "lambda_config_custom_message" {
  description = "ARN of the Lambda for custom message trigger"
  type        = string
  default     = null
}

variable "lambda_config_define_auth_challenge" {
  description = "ARN of the Lambda defining the authentication challenge"
  type        = string
  default     = null
}

variable "lambda_config_post_authentication" {
  description = "ARN of the Lambda for post-authentication trigger"
  type        = string
  default     = null
}

variable "lambda_config_post_confirmation" {
  description = "ARN of the Lambda for post-confirmation trigger"
  type        = string
  default     = null
}

variable "lambda_config_pre_authentication" {
  description = "ARN of the Lambda for pre-authentication trigger"
  type        = string
  default     = null
}

variable "lambda_config_pre_sign_up" {
  description = "ARN of the Lambda for pre-signup trigger"
  type        = string
  default     = null
}

variable "lambda_config_pre_token_generation" {
  description = "ARN of the Lambda for pre-token generation trigger"
  type        = string
  default     = null
}
variable "lambda_config_user_migration" {
  description = "ARN of the Lambda for user migration trigger"
  type        = string
  default     = null
}

variable "lambda_config_verify_auth_challenge_response" {
  description = "ARN of the Lambda verifying the authentication challenge response"
  type        = string
  default     = null
}

variable "lambda_config_custom_email_sender_lambda_arn" {
  description = "ARN of the Lambda for custom email sender"
  type        = string
  default     = null
}

variable "lambda_config_custom_email_sender_lambda_version" {
  description = "Version of the Lambda for custom email sender"
  type        = string
  default     = "V1_0"
}

variable "lambda_config_custom_sms_sender_lambda_arn" {
  description = "ARN of the Lambda for custom SMS sender"
  type        = string
  default     = null
}

variable "lambda_config_custom_sms_sender_lambda_version" {
  description = "Version of the Lambda for custom SMS sender"
  type        = string
  default     = "V1_0"
}

variable "lambda_config_kms_key_id" {
  description = "KMS key ID for encrypting custom email/SMS sender Lambda config"
  type        = string
  default     = null
}

variable "lambda_config_pre_token_generation_config_lambda_arn" {
  description = "ARN of the Lambda for pre-token generation config"
  type        = string
  default     = null
}

variable "lambda_config_pre_token_generation_config_lambda_version" {
  description = "Version of the Lambda for pre-token generation config"
  type        = string
  default     = "V2_0"
}

# ==============================================================================
# CUSTOM SCHEMAS
# ==============================================================================

variable "schemas" {
  description = "List of custom schema attributes"
  type = list(object({
    name                     = string
    attribute_data_type      = string
    developer_only_attribute = optional(bool)
    mutable                  = optional(bool)
    required                 = optional(bool)
    min_value                = optional(number)
    max_value                = optional(number)
    min_length               = optional(number)
    max_length               = optional(number)
  }))
  default = []
}

# ==============================================================================
# ADVANCED SECURITY
# ==============================================================================

variable "enable_advanced_security" {
  description = "Enable advanced security features"
  type        = bool
  default     = false
}

variable "advanced_security_mode" {
  description = "Advanced security mode: OFF, AUDIT, or ENFORCED"
  type        = string
  default     = "AUDIT"

  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be OFF, AUDIT, or ENFORCED"
  }
}

# ==============================================================================
# VERIFICATION MESSAGE TEMPLATE
# ==============================================================================

variable "verification_message_template_default_email_option" {
  description = "Default email option: CONFIRM_WITH_LINK or CONFIRM_WITH_CODE"
  type        = string
  default     = null

  validation {
    condition     = var.verification_message_template_default_email_option == null ? true : contains(["CONFIRM_WITH_LINK", "CONFIRM_WITH_CODE"], var.verification_message_template_default_email_option)
    error_message = "Default email option must be CONFIRM_WITH_LINK or CONFIRM_WITH_CODE"
  }
}

variable "verification_message_template_email_message" {
  description = "Email message template for verification"
  type        = string
  default     = null
}

variable "verification_message_template_email_message_by_link" {
  description = "Email message template when using confirmation link"
  type        = string
  default     = null
}

variable "verification_message_template_email_subject" {
  description = "Email subject for verification"
  type        = string
  default     = null
}

variable "verification_message_template_email_subject_by_link" {
  description = "Email subject when using confirmation link"
  type        = string
  default     = null
}

variable "verification_message_template_sms_message" {
  description = "SMS message template for verification"
  type        = string
  default     = null
}

# ==============================================================================
# APP CLIENTS
# ==============================================================================

variable "app_clients" {
  description = "List of app clients to create"
  type = list(object({
    name                                          = string
    client_type                                   = optional(string)
    generate_secret                               = optional(bool)
    refresh_token_validity                        = optional(number)
    access_token_validity                         = optional(number)
    id_token_validity                             = optional(number)
    token_validity_units                          = optional(map(string))
    read_attributes                               = optional(list(string))
    write_attributes                              = optional(list(string))
    explicit_auth_flows                           = optional(list(string))
    supported_identity_providers                  = optional(list(string))
    callback_urls                                 = optional(list(string))
    logout_urls                                   = optional(list(string))
    default_redirect_uri                          = optional(string)
    allowed_oauth_flows                           = optional(list(string))
    allowed_oauth_flows_user_pool_client          = optional(bool)
    allowed_oauth_scopes                          = optional(list(string))
    analytics_configuration                       = optional(map(string))
    prevent_user_existence_errors                 = optional(string)
    enable_token_revocation                       = optional(bool)
    enable_propagate_additional_user_context_data = optional(bool)
    auth_session_validity                         = optional(number)
  }))
  default = []
}

# ==============================================================================
# DOMAIN
# ==============================================================================

variable "domain" {
  description = "Cognito domain for hosted UI"
  type        = string
  default     = null
}

variable "domain_certificate_arn" {
  description = "ACM certificate ARN for the domain"
  type        = string
  default     = null
}

variable "custom_domain" {
  description = "Custom domain name for hosted UI"
  type        = string
  default     = null
}

variable "custom_domain_certificate_arn" {
  description = "ACM certificate ARN for the custom domain"
  type        = string
  default     = null
}

# ==============================================================================
# UI CUSTOMIZATION
# ==============================================================================

variable "ui_customization_css" {
  description = "CSS for customizing the hosted UI"
  type        = string
  default     = null
}

variable "ui_customization_image_file" {
  description = "Path to the image file for UI customization"
  type        = string
  default     = null
}

variable "ui_customization_client_id" {
  description = "Client ID for UI customization (use 'ALL' for all clients)"
  type        = string
  default     = "ALL"
}

# ==============================================================================
# USER GROUPS
# ==============================================================================

variable "user_groups" {
  description = "List of user groups to create"
  type = list(object({
    name        = string
    description = optional(string)
    precedence  = optional(number)
    role_arn    = optional(string)
  }))
  default = []
}

# ==============================================================================
# IDENTITY PROVIDERS
# ==============================================================================

variable "identity_providers" {
  description = "List of identity providers to configure"
  type = list(object({
    provider_name     = string
    provider_type     = string
    provider_details  = map(string)
    attribute_mapping = optional(map(string))
    idp_identifiers   = optional(list(string))
  }))
  default = []
}

# ==============================================================================
# RESOURCE SERVERS
# ==============================================================================

variable "resource_servers" {
  description = "List of resource servers for OAuth scopes"
  type = list(object({
    identifier = string
    name       = string
    scopes = optional(list(object({
      scope_name        = string
      scope_description = string
    })))
  }))
  default = []
}

# ==============================================================================
# WAF ASSOCIATION
# ==============================================================================

variable "waf_web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL to associate with the Cognito User Pool"
  type        = string
  default     = null
}

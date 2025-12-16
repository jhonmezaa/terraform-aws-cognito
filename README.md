# AWS Cognito User Pool Terraform Module

Production-ready Terraform module for creating and managing AWS Cognito User Pools with comprehensive configuration options including OAuth flows, MFA, advanced security, custom domains, and identity provider integrations.

## Features

- **User Pool Tiers**: Support for LITE, ESSENTIALS, and PLUS tiers
- **Authentication**: Email and phone-based authentication with customizable attributes
- **MFA Support**: Optional, required, or disabled multi-factor authentication with SMS and software tokens
- **Password Policies**: Comprehensive password requirements and temporary password validity
- **Advanced Security**: Risk-based adaptive authentication with AUDIT or ENFORCED modes
- **App Clients**: Multiple app clients with OAuth 2.0 flows (authorization code, implicit)
- **Custom Domains**: Support for standard Cognito domains and custom domains with ACM certificates
- **UI Customization**: Custom CSS and logo for hosted UI
- **Resource Servers**: Define custom OAuth scopes for API access
- **Identity Providers**: Social login integration (Google, Facebook, Amazon, Apple, SAML, OIDC)
- **User Groups**: Organize users with role-based access control
- **Custom Schemas**: Define custom user attributes with type validation
- **Lambda Triggers**: Pre/post authentication, token generation, and user migration hooks
- **Account Recovery**: Email and phone-based account recovery mechanisms
- **Deletion Protection**: Prevent accidental deletion of user pools
- **Email/SMS Configuration**: Custom email and SMS delivery with SES and SNS
- **Device Tracking**: Remember and track user devices
- **Consistent Naming**: Follows monorepo naming convention `{region_prefix}-cognito-{account}-{project}`

## Usage

### Basic Example

```hcl
module "cognito" {
  source = "./cognito"

  account_name = "dev"
  project_name = "myapp"
  environment  = "development"

  # Email-based authentication
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password policy
  password_minimum_length    = 8
  password_require_lowercase = true
  password_require_uppercase = true
  password_require_numbers   = true
  password_require_symbols   = false

  # App client
  app_clients = [
    {
      name                = "web-app"
      generate_secret     = false
      explicit_auth_flows = [
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH"
      ]
    }
  ]

  tags = {
    Environment = "dev"
  }
}
```

### Production Example with MFA

```hcl
module "cognito" {
  source = "./cognito"

  account_name = "prod"
  project_name = "myapp"
  environment  = "production"

  # User Pool Tier
  user_pool_tier = "PLUS"

  # Authentication
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Strong password policy
  password_minimum_length    = 12
  password_require_lowercase = true
  password_require_uppercase = true
  password_require_numbers   = true
  password_require_symbols   = true

  # Require MFA
  mfa_configuration        = "ON"
  enable_software_token_mfa = true

  # Advanced Security
  enable_advanced_security = true
  advanced_security_mode   = "ENFORCED"

  # Deletion Protection
  deletion_protection = "ACTIVE"

  # App clients
  app_clients = [
    {
      name                         = "web-app"
      generate_secret              = true
      refresh_token_validity       = 30
      access_token_validity        = 60
      id_token_validity            = 60
      prevent_user_existence_errors = "ENABLED"
      enable_token_revocation       = true
      explicit_auth_flows          = [
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH"
      ]
    }
  ]

  # User groups
  user_groups = [
    {
      name        = "admins"
      description = "Administrator group"
      precedence  = 1
    },
    {
      name        = "users"
      description = "Regular users"
      precedence  = 10
    }
  ]

  tags = {
    Environment = "production"
    Compliance  = "required"
  }
}
```

### Advanced Example with OAuth

```hcl
module "cognito" {
  source = "./cognito"

  account_name = "prod"
  project_name = "api"
  environment  = "production"

  user_pool_tier = "PLUS"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_minimum_length  = 10
  password_require_lowercase = true
  password_require_uppercase = true
  password_require_numbers   = true
  password_require_symbols   = true

  mfa_configuration = "OPTIONAL"

  enable_advanced_security = true
  advanced_security_mode   = "AUDIT"

  # App client with OAuth
  app_clients = [
    {
      name                         = "web-app"
      generate_secret              = true
      refresh_token_validity       = 30
      access_token_validity        = 60
      id_token_validity            = 60
      explicit_auth_flows          = [
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_CUSTOM_AUTH"
      ]
      supported_identity_providers = ["COGNITO", "Google"]
      callback_urls                = [
        "https://myapp.example.com/callback",
        "http://localhost:3000/callback"
      ]
      logout_urls                  = [
        "https://myapp.example.com/logout",
        "http://localhost:3000/logout"
      ]
      default_redirect_uri         = "https://myapp.example.com/callback"
      allowed_oauth_flows          = ["code", "implicit"]
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes                 = [
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

  # Hosted UI domain
  domain = "prod-api-auth"

  # Resource servers for custom OAuth scopes
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

  # User groups
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

  # Custom schemas
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
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Inputs

### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| account_name | Account name for resource naming (e.g., 'prod', 'dev') | `string` |
| project_name | Project name for resource naming (e.g., 'myapp', 'api') | `string` |

### Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| region_prefix | Override the region prefix (defaults to automatic mapping) | `string` | `null` |
| environment | Environment name (e.g., 'production', 'development') | `string` | `"development"` |
| user_pool_tier | User pool tier: LITE, ESSENTIALS, or PLUS | `string` | `"ESSENTIALS"` |
| deletion_protection | Deletion protection: ACTIVE or INACTIVE | `string` | `"INACTIVE"` |
| username_attributes | User sign-in attributes (email, phone_number) | `list(string)` | `["email"]` |
| auto_verified_attributes | Attributes to be auto-verified (email, phone_number) | `list(string)` | `["email"]` |
| alias_attributes | Attributes supported as aliases (email, phone_number, preferred_username) | `list(string)` | `[]` |
| mfa_configuration | MFA configuration: OFF, ON, or OPTIONAL | `string` | `"OPTIONAL"` |
| enable_sms_mfa | Enable SMS-based MFA | `bool` | `false` |
| enable_software_token_mfa | Enable software token MFA (TOTP) | `bool` | `true` |
| password_minimum_length | Minimum length of the password (6-99) | `number` | `8` |
| password_require_lowercase | Require lowercase letters in password | `bool` | `true` |
| password_require_uppercase | Require uppercase letters in password | `bool` | `true` |
| password_require_numbers | Require numbers in password | `bool` | `true` |
| password_require_symbols | Require symbols in password | `bool` | `false` |
| temporary_password_validity_days | Days that a temporary password is valid (1-365) | `number` | `7` |
| enable_advanced_security | Enable advanced security features | `bool` | `false` |
| advanced_security_mode | Advanced security mode: OFF, AUDIT, or ENFORCED | `string` | `"OFF"` |
| app_clients | List of app clients to create | `list(object)` | `[]` |
| domain | Domain prefix for the user pool (for hosted UI) | `string` | `null` |
| custom_domain | Custom domain for the user pool | `string` | `null` |
| custom_domain_certificate_arn | ACM certificate ARN for custom domain | `string` | `null` |
| ui_customization_css | CSS for UI customization | `string` | `null` |
| ui_customization_image_file | Path to logo file for UI customization | `string` | `null` |
| resource_servers | List of resource servers with custom OAuth scopes | `list(object)` | `[]` |
| identity_providers | List of identity providers (Google, Facebook, etc.) | `list(object)` | `[]` |
| user_groups | List of user groups | `list(object)` | `[]` |
| schemas | List of custom schema attributes | `list(object)` | `[]` |
| ignore_schema_changes | Ignore changes to schema after creation | `bool` | `false` |
| email_sending_account | Email sending account: COGNITO_DEFAULT or DEVELOPER | `string` | `"COGNITO_DEFAULT"` |
| email_source_arn | ARN of SES verified email identity | `string` | `null` |
| email_from_address | From email address | `string` | `null` |
| email_reply_to_address | Reply-to email address | `string` | `null` |
| sms_external_id | External ID for SNS role | `string` | `null` |
| sms_sns_caller_arn | ARN of SNS caller role | `string` | `null` |
| sms_authentication_message | SMS authentication message | `string` | `null` |
| email_verification_subject | Email verification subject | `string` | `null` |
| email_verification_message | Email verification message | `string` | `null` |
| sms_verification_message | SMS verification message | `string` | `null` |
| device_only_remembered_on_user_prompt | Whether to remember devices only on user prompt | `bool` | `false` |
| challenge_required_on_new_device | Whether to challenge on new device | `bool` | `false` |
| enable_username_case_sensitivity | Enable username case sensitivity | `bool` | `false` |
| account_recovery_mechanisms | Account recovery mechanisms | `list(object)` | See defaults |
| lambda_create_auth_challenge | ARN of Create Auth Challenge Lambda | `string` | `null` |
| lambda_custom_message | ARN of Custom Message Lambda | `string` | `null` |
| lambda_define_auth_challenge | ARN of Define Auth Challenge Lambda | `string` | `null` |
| lambda_post_authentication | ARN of Post Authentication Lambda | `string` | `null` |
| lambda_post_confirmation | ARN of Post Confirmation Lambda | `string` | `null` |
| lambda_pre_authentication | ARN of Pre Authentication Lambda | `string` | `null` |
| lambda_pre_sign_up | ARN of Pre Sign Up Lambda | `string` | `null` |
| lambda_pre_token_generation | ARN of Pre Token Generation Lambda | `string` | `null` |
| lambda_user_migration | ARN of User Migration Lambda | `string` | `null` |
| lambda_verify_auth_challenge_response | ARN of Verify Auth Challenge Response Lambda | `string` | `null` |
| lambda_kms_key_id | KMS key ID for Lambda config encryption | `string` | `null` |
| tags | Additional tags for resources | `map(string)` | `{}` |

### App Client Object Structure

```hcl
{
  name                                     = string
  generate_secret                          = bool (optional, default: false)
  refresh_token_validity                   = number (optional, default: 30)
  access_token_validity                    = number (optional, default: 60)
  id_token_validity                        = number (optional, default: 60)
  token_validity_units                     = object (optional)
  explicit_auth_flows                      = list(string) (optional)
  read_attributes                          = list(string) (optional)
  write_attributes                         = list(string) (optional)
  supported_identity_providers             = list(string) (optional)
  callback_urls                            = list(string) (optional)
  logout_urls                              = list(string) (optional)
  default_redirect_uri                     = string (optional)
  allowed_oauth_flows                      = list(string) (optional)
  allowed_oauth_flows_user_pool_client     = bool (optional)
  allowed_oauth_scopes                     = list(string) (optional)
  prevent_user_existence_errors            = string (optional)
  enable_token_revocation                  = bool (optional)
  enable_propagate_additional_user_context_data = bool (optional)
  auth_session_validity                    = number (optional)
  analytics_configuration                  = object (optional)
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the user pool |
| arn | The ARN of the user pool |
| name | The name of the user pool |
| endpoint | The endpoint of the user pool |
| creation_date | The date the user pool was created |
| last_modified_date | The date the user pool was last modified |
| tier | The tier of the user pool |
| client_ids | Map of app client names to their IDs |
| client_secrets | Map of app client names to their secrets (sensitive) |
| domain | The domain prefix for the user pool |
| domain_cloudfront_distribution | CloudFront distribution ARN for standard domain |
| custom_domain | The custom domain for the user pool |
| custom_domain_cloudfront_distribution | CloudFront distribution ARN for custom domain |
| resource_server_ids | Map of resource server identifiers to IDs |
| resource_server_identifiers | List of resource server identifiers |
| resource_server_scope_identifiers | Map of resource server identifiers to their scope identifiers |
| identity_provider_names | List of identity provider names |
| user_group_names | List of user group names |
| user_group_arns | Map of user group names to their ARNs |
| estimated_number_of_users | Estimated number of users in the pool |

## Examples

The module includes three complete examples:

1. **[basic](examples/basic/)** - Simple user pool with email authentication and optional MFA
2. **[production](examples/production/)** - Production-ready configuration with MFA required, advanced security, and deletion protection
3. **[advanced](examples/advanced/)** - OAuth flows, resource servers with custom scopes, and identity provider integration

## User Pool Tiers

AWS Cognito offers three tiers with different feature sets:

- **LITE**: Basic authentication with limited monthly active users
- **ESSENTIALS**: Standard features with higher MAU limits
- **PLUS**: Advanced features including advanced security, risk-based authentication

## Advanced Security

When enabled, advanced security provides:
- Risk-based adaptive authentication
- Compromised credential checking
- Anomaly detection
- IP-based rate limiting

Modes:
- **AUDIT**: Logs security events without blocking
- **ENFORCED**: Actively blocks suspicious authentication attempts

## OAuth Flows

The module supports OAuth 2.0 flows:
- **Authorization Code**: Server-side applications (most secure)
- **Implicit**: Single-page applications (client-side)

Configure via `allowed_oauth_flows` in app client configuration.

## Identity Providers

Supported identity providers:
- **Social**: Google, Facebook, Amazon, Apple
- **SAML**: Enterprise SAML 2.0 providers
- **OIDC**: OpenID Connect providers

## Resource Servers

Define custom OAuth scopes for your APIs:

```hcl
resource_servers = [
  {
    identifier = "my-api"
    name       = "My API"
    scopes = [
      {
        scope_name        = "read"
        scope_description = "Read access"
      },
      {
        scope_name        = "write"
        scope_description = "Write access"
      }
    ]
  }
]
```

Access scopes in app client as: `my-api/read`, `my-api/write`

## Custom Schemas

Add custom user attributes:

```hcl
schemas = [
  {
    name                = "company"
    attribute_data_type = "String"
    mutable             = true
    required            = false
    min_length          = 1
    max_length          = 100
  }
]
```

**Important**: Schema attributes cannot be deleted or modified after creation. Set `ignore_schema_changes = true` to prevent Terraform from attempting updates.

## Lambda Triggers

Integrate Lambda functions for custom authentication flows:

- `lambda_pre_sign_up` - Custom validation before registration
- `lambda_post_confirmation` - Actions after user confirms
- `lambda_pre_authentication` - Custom checks before login
- `lambda_post_authentication` - Actions after successful login
- `lambda_pre_token_generation` - Modify claims before token generation
- `lambda_user_migration` - Migrate users from existing system
- `lambda_custom_message` - Customize verification messages
- `lambda_define_auth_challenge` - Define custom auth challenges
- `lambda_create_auth_challenge` - Create custom auth challenges
- `lambda_verify_auth_challenge_response` - Verify custom auth challenges

## Account Recovery

Configure account recovery mechanisms:

```hcl
account_recovery_mechanisms = [
  {
    name     = "verified_email"
    priority = 1
  },
  {
    name     = "verified_phone_number"
    priority = 2
  }
]
```

## Naming Convention

All resources follow the monorepo naming convention:

```
{region_prefix}-cognito-{account_name}-{project_name}
```

Examples:
- `ause1-cognito-prod-myapp` (us-east-1, prod, myapp)
- `euw1-cognito-dev-api` (eu-west-1, dev, api)

## License

MIT License - see LICENSE file for details

## Author

Created as part of the terraform-aws monorepo.

## References

- [AWS Cognito User Pools Documentation](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html)
- [Terraform AWS Cognito Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool)

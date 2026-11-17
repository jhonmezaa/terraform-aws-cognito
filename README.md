# AWS Cognito User Pool Terraform Module

Production-ready Terraform module for creating and managing AWS Cognito User Pools with comprehensive configuration options including OAuth flows, MFA, advanced security, custom domains, and identity provider integrations.

## Features

- **User Pool Tiers**: Support for LITE, ESSENTIALS, and PLUS tiers
- **Authentication**: Email and phone-based authentication with customizable attributes
- **MFA Support**: Optional, required, or disabled multi-factor authentication with SMS and software tokens
- **Passkeys and Email MFA**: WebAuthn configuration and email MFA messages (ESSENTIALS/PLUS tiers)
- **WAF**: Optional WAFv2 Web ACL association
- **Password Policies**: Comprehensive password requirements, password history and temporary password validity
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
  source = "github.com/jhonmezaa/terraform-aws-cognito//cognito?ref=v1.4.0"

  account_name = "dev"
  project_name = "myapp"
  environment  = "development"

  # Email-based authentication
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password policy
  password_minimum_length  = 8
  password_require_symbols = false

  # App client
  app_clients = [
    {
      name            = "web-app"
      generate_secret = false
      explicit_auth_flows = [
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH"
      ]
    }
  ]

  tags_common = {
    Owner = "platform"
  }
}
```

### Production Example with MFA

```hcl
module "cognito" {
  source = "github.com/jhonmezaa/terraform-aws-cognito//cognito?ref=v1.4.0"

  account_name = "prod"
  project_name = "myapp"
  environment  = "production"

  user_pool_tier = "PLUS"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Strong password policy
  password_minimum_length = 12
  password_history_size   = 5

  # Require MFA (software token / TOTP is enabled automatically when MFA is ON or OPTIONAL)
  mfa_configuration = "ON"

  # Advanced security (threat protection)
  enable_advanced_security = true
  advanced_security_mode   = "ENFORCED"

  deletion_protection = "ACTIVE"

  app_clients = [
    {
      name                          = "web-app"
      generate_secret               = true
      prevent_user_existence_errors = "ENABLED"
      enable_token_revocation       = true
    }
  ]

  user_groups = [
    { name = "admins", description = "Administrator group", precedence = 1 },
    { name = "users", description = "Regular users", precedence = 10 },
  ]
}
```

### OAuth Example

See [examples/advanced](examples/advanced/) for a complete OAuth 2.0 configuration with a hosted UI domain, resource servers with custom scopes and a (commented) Google identity provider.

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.3  |
| aws       | >= 6.0  |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | >= 6.0  |

## Resources

| Name | Type |
| ---- | ---- |
| aws_cognito_user_pool.this | resource |
| aws_cognito_user_pool_client.this | resource |
| aws_cognito_user_pool_domain.this | resource |
| aws_cognito_user_pool_domain.custom | resource |
| aws_cognito_user_pool_ui_customization.this | resource |
| aws_cognito_user_group.this | resource |
| aws_cognito_identity_provider.this | resource |
| aws_cognito_resource_server.this | resource |
| aws_wafv2_web_acl_association.cognito_user_pool | resource |
| aws_region.current | data source |

## Inputs

### Required Inputs

| Name | Description | Type |
| ---- | ----------- | ---- |
| account_name | Account name for resource naming (e.g., 'prod', 'dev', 'staging') | `string` |
| project_name | Project name for resource naming (e.g., 'myapp', 'api') | `string` |

### Optional Inputs

| Name | Description | Type | Default |
| ---- | ----------- | ---- | ------- |
| region_prefix | Region prefix for naming. If null, auto-detected from current region | `string` | `null` |
| use_region_prefix | Whether to include the region prefix in resource names. When false, names omit the region prefix. | `bool` | `true` |
| environment | Environment name (e.g., 'production', 'development', 'staging') | `string` | `"production"` |
| user_pool_name | Explicit user pool name. When null, the name is generated as {region_prefix}-cognito-{account_name}-{project_name} | `string` | `null` |
| tags_common | Common tags applied to every taggable resource (merged first, so module and specific tags take precedence) | `map(string)` | `{}` |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` |
| user_pool_tags | Additional tags specific to the user pool | `map(string)` | `{}` |
| user_pool_tier | User pool tier: LITE, ESSENTIALS, or PLUS | `string` | `"ESSENTIALS"` |
| alias_attributes | Attributes supported as an alias for this user pool (email, phone_number, preferred_username) | `list(string)` | `null` |
| username_attributes | Whether email addresses or phone numbers can be specified as usernames when a user signs up | `list(string)` | `[]` |
| auto_verified_attributes | Attributes to be auto-verified (email, phone_number) | `list(string)` | `["email"]` |
| case_sensitive | Whether username case sensitivity will be applied for all users in the user pool | `bool` | `false` |
| deletion_protection | When active, prevents accidental deletion of your user pool | `string` | `"ACTIVE"` |
| mfa_configuration | Multi-factor authentication configuration: OFF, ON, or OPTIONAL | `string` | `"OPTIONAL"` |
| email_mfa_configuration | Email MFA message configuration (requires ESSENTIALS or PLUS tier and DEVELOPER email sending). message must contain {####} | `object` | `null` |
| web_authn_configuration | WebAuthn (passkeys) configuration. Requires ESSENTIALS or PLUS tier. user_verification: required or preferred | `object` | `null` |
| password_minimum_length | Minimum length of the password policy | `number` | `8` |
| password_require_lowercase | Whether to require lowercase characters in passwords | `bool` | `true` |
| password_require_uppercase | Whether to require uppercase characters in passwords | `bool` | `true` |
| password_require_numbers | Whether to require numbers in passwords | `bool` | `true` |
| password_require_symbols | Whether to require symbols in passwords | `bool` | `true` |
| password_history_size | Number of previous passwords users are prevented from reusing (0-24). Requires ESSENTIALS or PLUS tier. Null leaves the AWS default | `number` | `null` |
| temporary_password_validity_days | Number of days a temporary password is valid | `number` | `7` |
| sign_in_policy_allowed_first_auth_factors | List of allowed first authentication factors (PASSWORD, WEB_AUTHN, EMAIL_OTP, SMS_OTP) | `list(string)` | `[]` |
| attributes_require_verification_before_update | Attributes that require verification before update (email, phone_number) | `list(string)` | `[]` |
| recovery_mechanisms | List of account recovery options | `list(object)` | `[{ name = "verified_email", priority = 1 }]` |
| admin_create_user_config_allow_admin_create_user_only | Set to true if only the administrator is allowed to create user profiles | `bool` | `false` |
| admin_create_user_config_email_message | Message template for email messages | `string` | `null` |
| admin_create_user_config_email_subject | Subject line for email messages | `string` | `null` |
| admin_create_user_config_sms_message | Message template for SMS messages | `string` | `null` |
| device_configuration_challenge_required_on_new_device | Whether a challenge is required on a new device | `bool` | `null` |
| device_configuration_device_only_remembered_on_user_prompt | Whether a device is only remembered on user prompt | `bool` | `null` |
| email_configuration_source_arn | ARN of the SES verified email identity to use for sending emails | `string` | `null` |
| email_configuration_from_email_address | Email address to send emails from | `string` | `null` |
| email_configuration_reply_to_email_address | Reply-to email address | `string` | `null` |
| email_configuration_email_sending_account | Email sending account type: COGNITO_DEFAULT or DEVELOPER | `string` | `"COGNITO_DEFAULT"` |
| email_configuration_configuration_set | SES configuration set name | `string` | `null` |
| sms_configuration_external_id | External ID used in IAM role trust policy | `string` | `null` |
| sms_configuration_sns_caller_arn | ARN of the IAM role that allows Cognito to send SMS messages | `string` | `null` |
| sms_configuration_sns_region | AWS Region to use for SNS (if different from current region) | `string` | `null` |
| lambda_config_create_auth_challenge | ARN of the Lambda creating an authentication challenge | `string` | `null` |
| lambda_config_custom_message | ARN of the Lambda for custom message trigger | `string` | `null` |
| lambda_config_define_auth_challenge | ARN of the Lambda defining the authentication challenge | `string` | `null` |
| lambda_config_post_authentication | ARN of the Lambda for post-authentication trigger | `string` | `null` |
| lambda_config_post_confirmation | ARN of the Lambda for post-confirmation trigger | `string` | `null` |
| lambda_config_pre_authentication | ARN of the Lambda for pre-authentication trigger | `string` | `null` |
| lambda_config_pre_sign_up | ARN of the Lambda for pre-signup trigger | `string` | `null` |
| lambda_config_pre_token_generation | ARN of the Lambda for pre-token generation trigger | `string` | `null` |
| lambda_config_user_migration | ARN of the Lambda for user migration trigger | `string` | `null` |
| lambda_config_verify_auth_challenge_response | ARN of the Lambda verifying the authentication challenge response | `string` | `null` |
| lambda_config_custom_email_sender_lambda_arn | ARN of the Lambda for custom email sender | `string` | `null` |
| lambda_config_custom_email_sender_lambda_version | Version of the Lambda for custom email sender | `string` | `"V1_0"` |
| lambda_config_custom_sms_sender_lambda_arn | ARN of the Lambda for custom SMS sender | `string` | `null` |
| lambda_config_custom_sms_sender_lambda_version | Version of the Lambda for custom SMS sender | `string` | `"V1_0"` |
| lambda_config_kms_key_id | KMS key ID for encrypting custom email/SMS sender Lambda config | `string` | `null` |
| lambda_config_pre_token_generation_config_lambda_arn | ARN of the Lambda for pre-token generation config | `string` | `null` |
| lambda_config_pre_token_generation_config_lambda_version | Version of the Lambda for pre-token generation config | `string` | `"V2_0"` |
| schemas | List of custom schema attributes | `list(object)` | `[]` |
| enable_advanced_security | Enable advanced security features | `bool` | `false` |
| advanced_security_mode | Advanced security mode: OFF, AUDIT, or ENFORCED | `string` | `"AUDIT"` |
| advanced_security_additional_flows | Threat protection mode for custom authentication flows (custom_auth_mode): AUDIT or ENFORCED. Only applied when enable_advanced_security = true | `string` | `null` |
| verification_message_template_default_email_option | Default email option: CONFIRM_WITH_LINK or CONFIRM_WITH_CODE | `string` | `null` |
| verification_message_template_email_message | Email message template for verification | `string` | `null` |
| verification_message_template_email_message_by_link | Email message template when using confirmation link | `string` | `null` |
| verification_message_template_email_subject | Email subject for verification | `string` | `null` |
| verification_message_template_email_subject_by_link | Email subject when using confirmation link | `string` | `null` |
| verification_message_template_sms_message | SMS message template for verification | `string` | `null` |
| app_clients | List of app clients to create | `list(object)` | `[]` |
| domain | Cognito domain for hosted UI | `string` | `null` |
| domain_certificate_arn | ACM certificate ARN for the domain | `string` | `null` |
| managed_login_version | Managed login version for the domain (1 = classic Hosted UI, 2 = Managed Login). Required for ESSENTIALS/PLUS tiers with PASSWORD auth factor. | `number` | `null` |
| custom_domain | Custom domain name for hosted UI | `string` | `null` |
| custom_domain_certificate_arn | ACM certificate ARN for the custom domain | `string` | `null` |
| ui_customization_css | CSS for customizing the hosted UI | `string` | `null` |
| ui_customization_image_file | Path to the image file for UI customization | `string` | `null` |
| ui_customization_client_id | Client ID for UI customization (use 'ALL' for all clients) | `string` | `"ALL"` |
| user_groups | List of user groups to create | `list(object)` | `[]` |
| identity_providers | List of identity providers to configure | `list(object)` | `[]` |
| resource_servers | List of resource servers for OAuth scopes | `list(object)` | `[]` |
| waf_web_acl_arn | ARN of the WAFv2 Web ACL to associate with the Cognito User Pool | `string` | `null` |

### App Client Object Structure

Omitted (or `null`) attributes take the default shown below.

```hcl
{
  name                                          = string
  generate_secret                               = bool (optional, default: false)
  refresh_token_validity                        = number (optional, default: 30)
  access_token_validity                         = number (optional, default: 60)
  id_token_validity                             = number (optional, default: 60)
  token_validity_units                          = map(string) (optional, default: { access_token = "minutes", id_token = "minutes", refresh_token = "days" })
  explicit_auth_flows                           = list(string) (optional, default: ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"])
  read_attributes                               = list(string) (optional)
  write_attributes                              = list(string) (optional)
  supported_identity_providers                  = list(string) (optional, default: ["COGNITO"])
  callback_urls                                 = list(string) (optional)
  logout_urls                                   = list(string) (optional)
  default_redirect_uri                          = string (optional)
  allowed_oauth_flows                           = list(string) (optional)
  allowed_oauth_flows_user_pool_client          = bool (optional, default: false)
  allowed_oauth_scopes                          = list(string) (optional)
  analytics_configuration                       = map(string) (optional)
  prevent_user_existence_errors                 = string (optional, default: "ENABLED")
  enable_token_revocation                       = bool (optional, default: true)
  enable_propagate_additional_user_context_data = bool (optional, default: false)
  auth_session_validity                         = number (optional, default: 3)
}
```

## Outputs

| Name | Description |
| ---- | ----------- |
| id | The ID of the user pool |
| arn | The ARN of the user pool |
| name | The name of the user pool |
| endpoint | The endpoint name of the user pool |
| creation_date | The date the user pool was created |
| last_modified_date | The date the user pool was last modified |
| custom_domain | The custom domain name for the user pool |
| estimated_number_of_users | A number estimating the size of the user pool |
| user_pool_tier | The tier of the user pool (LITE, ESSENTIALS, or PLUS) |
| oidc_issuer_url | The OIDC issuer URL for the user pool (https://cognito-idp.{region}.amazonaws.com/{user_pool_id}) |
| jwks_uri | The JWKS URI for the user pool (used to verify JWT signatures) |
| client_ids | The IDs of the user pool clients |
| client_secrets | The client secrets of the user pool clients (sensitive) |
| domain | The domain name for the user pool |
| domain_aws_account_id | The AWS account ID for the user pool domain |
| domain_cloudfront_distribution | The CloudFront distribution ARN for the domain |
| domain_cloudfront_distribution_arn | The ARN of the CloudFront distribution for the domain |
| domain_cloudfront_distribution_zone_id | The CloudFront distribution zone ID for the domain (for Route53 alias records) |
| domain_s3_bucket | The S3 bucket where the static files for the domain are stored |
| domain_version | The app version for the domain |
| custom_domain_name | The custom domain name |
| custom_domain_cloudfront_distribution_arn | The ARN of the CloudFront distribution for the custom domain |
| user_group_names | List of user group names |
| user_group_names_map | Map of user group keys to their names |
| user_group_names_list | DEPRECATED: returns a map (not a list) of user group keys to their names; use user_group_names_map for the map or user_group_names for a list. Kept for backward compatibility |
| user_group_ids | Map of user group keys to their IDs |
| user_group_arns | Map of user group keys to their ARNs (arn:aws:cognito-idp:<region>:<account>:userpool/<pool-id>/group/<name>) |
| name_prefix | Name prefix used for generated resource names (empty when use_region_prefix = false) |
| user_groups_map | Complete map of user groups with all attributes |
| identity_provider_names | List of identity provider names |
| resource_server_ids | Map of resource server identifiers to their IDs |
| resource_server_identifiers | List of resource server identifiers |
| resource_server_scope_identifiers | Map of resource server identifiers to their scope identifiers |

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

**Important**: Schema attributes cannot be deleted or modified after creation; changing an existing entry in `schemas` makes the apply fail.

## Lambda Triggers

Integrate Lambda functions for custom authentication flows:

- `lambda_config_pre_sign_up` - Custom validation before registration
- `lambda_config_post_confirmation` - Actions after user confirms
- `lambda_config_pre_authentication` - Custom checks before login
- `lambda_config_post_authentication` - Actions after successful login
- `lambda_config_pre_token_generation` / `lambda_config_pre_token_generation_config_lambda_arn` - Modify claims before token generation
- `lambda_config_user_migration` - Migrate users from existing system
- `lambda_config_custom_message` - Customize verification messages
- `lambda_config_define_auth_challenge` - Define custom auth challenges
- `lambda_config_create_auth_challenge` - Create custom auth challenges
- `lambda_config_verify_auth_challenge_response` - Verify custom auth challenges
- `lambda_config_custom_email_sender_lambda_arn` / `lambda_config_custom_sms_sender_lambda_arn` - Custom senders (require `lambda_config_kms_key_id`)

## Account Recovery

Configure account recovery mechanisms:

```hcl
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
```

## Naming Convention

All resources follow the monorepo naming convention:

```
{region_prefix}-cognito-{account_name}-{project_name}
```

- `use_region_prefix = false` drops the `{region_prefix}-` part.
- `user_pool_name` sets an explicit name instead of the generated one.
- App clients are named `{user_pool_name}-{client name}`.
- Tags: `tags_common`, module tags (`Module`, `Region`, `Account`, `Project`, `Environment`), `tags`, `user_pool_tags`, then `Name` and `ManagedBy = "Terraform"`.

Examples:

- `ause1-cognito-prod-myapp` (us-east-1, prod, myapp)
- `euw1-cognito-dev-api` (eu-west-1, dev, api)

## License

MIT License - see LICENSE file for details

## Author

Created and maintained by [Jhon Meza](https://github.com/jhonmezaa).

## References

- [AWS Cognito User Pools Documentation](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html)
- [Terraform AWS Cognito Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool)

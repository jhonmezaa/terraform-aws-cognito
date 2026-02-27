# Changelog

## [v1.3.0] - 2026-02-27

### Changed
- Update AWS provider constraint to `~> 6.0` across module and examples


All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-02-27

### Added

#### OIDC/JWT Outputs
- Added `oidc_issuer_url` output (`https://cognito-idp.{region}.amazonaws.com/{user_pool_id}`)
- Added `jwks_uri` output (`https://.../.well-known/jwks.json`) for JWT signature verification
- Critical for integration with API Gateway, ALB, EKS IRSA, and any JWT-validating service

## [1.1.0] - 2026-02-27

### Added

#### WAF Integration
- Added `waf_web_acl_arn` variable for WAFv2 Web ACL association
- Added `9-waf-association.tf` with `aws_wafv2_web_acl_association` resource
- WAF association is optional (only created when `waf_web_acl_arn` is provided)

### Fixed

#### Variables Cleanup
- Removed orphan SSO variables (`provider_type`, `provider_name`, `attribute_mapping`, `MetadataURL`) that were not used by any resource
- Fixed `username_attributes` default from `null` to `[]` to prevent `length(null)` error
- Moved `waf_web_acl_arn` variable to its own properly labeled WAF section

#### Outputs Cleanup
- Removed duplicate `client_ids_map` output (identical to `client_ids`)
- Removed duplicate `domain_app_version` output (identical to `domain_version`)

#### Data Sources Cleanup
- Removed unused `data.aws_caller_identity.current` from `6-data.tf`

## [1.0.3] - 2024-12-16

### Changed

#### Repository
- Updated .gitignore to ignore .terraform.lock.hcl files
- Removed existing lock files from repository (4 files)
- Lock files should not be committed for reusable modules to avoid version conflicts

## [1.0.2] - 2024-12-16

### Changed

#### Documentation
- Updated author information in README.md with proper attribution

## [1.0.1] - 2024-12-16

### Added

#### Documentation
- Added comprehensive README.md with complete module documentation
- Usage examples for basic, production, and advanced scenarios
- Detailed inputs and outputs tables
- OAuth 2.0, MFA, and advanced security explanations
- Resource servers and custom scopes documentation
- Lambda triggers guide
- Account recovery configuration examples
- Naming convention documentation
- Links to AWS documentation and Terraform registry

## [1.0.0] - 2024-12-16

### 🎉 Initial Release

First production-ready release of the AWS Cognito User Pool Terraform module with comprehensive authentication and authorization features.

### Added

#### Core User Pool Features
- User Pool creation with customizable configuration
- Support for LITE, ESSENTIALS, and PLUS tiers
- Username and email authentication
- Auto-verified attributes (email, phone)
- Sign-in policy with allowed first auth factors
- User attribute update verification requirements
- Deletion protection (ACTIVE/INACTIVE)
- Automatic region prefix generation for resource naming
- Consistent resource naming convention across all resources

#### Password Policy
- Configurable minimum password length (6-99 characters)
- Require lowercase letters
- Require uppercase letters
- Require numbers
- Require symbols
- Temporary password validity (1-365 days)

#### Multi-Factor Authentication (MFA)
- MFA configuration modes: OFF, ON, OPTIONAL
- SMS-based MFA support
- Software token MFA (TOTP) support
- MFA configuration per user choice

#### Advanced Security
- Risk-based adaptive authentication (requires PLUS tier)
- Advanced security modes: OFF, AUDIT, ENFORCED
- Compromised credential checking
- Anomaly detection (unusual location, device)
- IP-based rate limiting
- CAPTCHA challenges for suspicious requests

#### App Clients
- Multiple app clients support via for_each pattern
- Client secret generation
- Token validity configuration (access, ID, refresh tokens)
- Token validity units (minutes, hours, days)
- Read/write attributes configuration
- Explicit authentication flows:
  - ALLOW_REFRESH_TOKEN_AUTH
  - ALLOW_USER_SRP_AUTH
  - ALLOW_USER_PASSWORD_AUTH
  - ALLOW_CUSTOM_AUTH
  - ALLOW_USER_AUTH
- OAuth 2.0 configuration
- Analytics configuration support
- Prevent user existence errors
- Token revocation support
- Propagate additional user context data
- Auth session validity

#### OAuth 2.0 Support
- Callback URLs configuration
- Logout URLs configuration
- Default redirect URI
- Allowed OAuth flows (code, implicit)
- OAuth flows user pool client toggle
- OAuth scopes (email, openid, profile, phone, custom)
- Supported identity providers integration

#### Domain and Hosted UI
- Standard Cognito domain support
- Custom domain with ACM certificate
- UI customization with CSS
- UI customization with logo image
- UI customization per client or globally

#### User Groups
- Multiple user groups via for_each pattern
- Group descriptions
- Precedence configuration (1-1000)
- IAM role assignment per group

#### Resource Servers
- Custom OAuth scopes for APIs
- Multiple resource servers support
- Scope name and description
- Automatic scope identifier generation

#### Identity Providers
- Social login support (Google, Facebook, Amazon, Apple)
- SAML 2.0 provider integration
- OpenID Connect (OIDC) provider support
- Attribute mapping from providers
- Provider details configuration

#### Custom Schemas
- String attributes with min/max length
- Number attributes with min/max value
- DateTime attributes
- Boolean attributes
- Mutable/immutable attributes
- Required/optional attributes
- Developer-only attributes

#### Lambda Triggers
- Pre sign-up trigger
- Post confirmation trigger
- Pre authentication trigger
- Post authentication trigger
- Pre token generation trigger
- Pre token generation v2 configuration
- User migration trigger
- Custom message trigger
- Define auth challenge trigger
- Create auth challenge trigger
- Verify auth challenge response trigger
- Custom email sender (with KMS)
- Custom SMS sender (with KMS)
- KMS key configuration for custom senders

#### Email Configuration
- Cognito default email (50 emails/day limit)
- Amazon SES integration (DEVELOPER mode)
- Custom source ARN
- Custom from email address
- Custom reply-to email address
- SES configuration set support

#### SMS Configuration
- SMS authentication messages
- SMS verification messages
- SNS caller ARN configuration
- External ID for SNS role
- SMS region configuration

#### Verification Messages
- Custom email verification templates
- Custom SMS verification templates
- Email verification subject
- Email verification message
- Email message by link
- Email subject by link
- Default email option (CONFIRM_WITH_CODE, CONFIRM_WITH_LINK)

#### Account Recovery
- Multiple recovery mechanisms
- Verified email recovery
- Verified phone number recovery
- Admin-only recovery
- Priority-based recovery order

#### Admin Create User
- Allow admin create user only mode
- Invite message templates
- Custom email message
- Custom email subject
- Custom SMS message

#### Device Configuration
- Challenge required on new device
- Device only remembered on user prompt

#### Outputs (30 total)
- User pool outputs (ID, ARN, name, endpoint, tier)
- Creation and modification dates
- Estimated number of users
- App client outputs (IDs, secrets, maps)
- Domain outputs (standard and custom)
- CloudFront distribution details
- CloudFront zone ID for Route53
- S3 bucket and version information
- User group outputs (names, IDs, complete map)
- Identity provider names
- Resource server outputs (IDs, identifiers, scope identifiers)

#### Examples
- **basic**: Simple user pool with email authentication (~$0.01/month)
- **production**: Production-ready with MFA and advanced security (~$0.05/month)
- **advanced**: Complete OAuth 2.0 with resource servers and custom scopes (~$0.05/month)

#### Documentation
- Comprehensive README with usage examples
- Feature comparison with reference module
- Complete variable documentation
- Output variable documentation
- Integration examples (API Gateway, ALB)
- Best practices guide
- Security recommendations
- Cost optimization tips

#### Code Quality
- Terraform 1.0+ compatibility
- AWS Provider 5.0+ compatibility
- Numbered file organization (0-8)
- Consistent code formatting
- Comprehensive variable validation
- Terraform validate passing for module and all examples
- For-each pattern for collections
- Dynamic blocks for optional features

### Fixed

#### Data Source Attributes
- Fixed `data.aws_region.current.name` to use `.id` attribute
- Resolved deprecated attribute warnings

#### Mutually Exclusive Arguments
- Fixed `alias_attributes` and `username_attributes` conflict
- Implemented conditional logic to prevent conflicts

#### Token Validity Units
- Fixed token validity units always explicitly set
- Prevented hour/minute/day confusion
- Access token: minutes (default)
- ID token: minutes (default)
- Refresh token: days (default)

#### Resource Dependencies
- Added explicit `depends_on` for resource servers before app clients
- Ensures custom OAuth scopes are available when creating clients

#### Reserved Words
- Domain validation prevents AWS reserved word "cognito"

#### App Client Configuration
- Removed unsupported `client_type` attribute
- Removed conditional lifecycle ignore_changes (not supported by Terraform)

### Technical Details

#### Supported Regions
- All AWS commercial regions
- Automatic region prefix mapping for 20+ regions
- Custom region prefix override support

#### Resource Limits
- Up to 1000 app clients per user pool
- Up to 50 user groups per user pool
- Up to 25 resource servers per user pool
- Up to 50 custom attributes per user pool
- AWS service quotas apply

#### Performance
- Efficient use of for_each over count
- Minimal resource dependencies
- Optimized data source queries
- Lazy evaluation of optional resources

#### Compatibility
- Terraform >= 1.0
- AWS Provider >= 5.0
- Compatible with Terraform Cloud
- Compatible with Terragrunt
- Module composition ready

### Dependencies

#### Required Providers
- hashicorp/aws >= 5.0

#### Terraform Version
- terraform >= 1.0

### Notes

- This is the first stable release (1.0.0)
- All features are production-ready
- Breaking changes will follow semantic versioning
- See examples for recommended usage patterns
- Cost estimates based on ESSENTIALS tier pricing as of Dec 2024
- Advanced security requires PLUS tier

### Migration Notes

This is the first release - no migration needed.

### Known Issues

None reported in this release.

### Contributors

- Initial implementation and release

---

## Release Checklist

- [x] All examples validated with `terraform validate`
- [x] README.md documentation complete
- [x] CHANGELOG.md created
- [x] All input variables documented
- [x] All outputs documented
- [x] Code formatted with `terraform fmt`
- [x] Examples cover all major use cases
- [x] Naming conventions consistent
- [x] Security best practices implemented
- [x] Validation against reference module completed
- [x] terraform.tfvars.example added to all examples
- [x] README.md added to each example

[1.2.0]: https://github.com/jhonmezaa/terraform-aws-cognito/releases/tag/v1.2.0
[1.1.0]: https://github.com/jhonmezaa/terraform-aws-cognito/releases/tag/v1.1.0
[1.0.3]: https://github.com/jhonmezaa/terraform-aws-cognito/releases/tag/v1.0.3
[1.0.2]: https://github.com/jhonmezaa/terraform-aws-cognito/releases/tag/v1.0.2
[1.0.1]: https://github.com/jhonmezaa/terraform-aws-cognito/releases/tag/v1.0.1
[1.0.0]: https://github.com/jhonmezaa/terraform-aws-cognito/releases/tag/v1.0.0

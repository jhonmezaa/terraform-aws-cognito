# Production Cognito User Pool Example

This example creates a production-ready AWS Cognito User Pool with enhanced security features, including required MFA and advanced security.

## Features

- ✅ PLUS tier (advanced security features)
- ✅ **MFA REQUIRED** for all users
- ✅ Advanced security ENFORCED
- ✅ Strong password policy (12 characters minimum)
- ✅ Deletion protection ACTIVE
- ✅ Multiple app clients (web, mobile, admin)
- ✅ User groups with precedence
- ✅ Hosted UI domain

## Cost Estimate

**~$0.05/month** for PLUS tier with minimal usage

- User Pool: PLUS tier pricing
- MAUs: First 50,000 users charged at PLUS tier rates
- Advanced Security: Included in PLUS tier

## Usage

### 1. Copy Variables File

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Customize Variables

Edit `terraform.tfvars`:

```hcl
account_name = "prod"
project_name = "myapp"
environment  = "production"
```

### 3. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

## Testing the User Pool

After deployment:

```bash
# Get outputs
export USER_POOL_ID=$(terraform output -raw user_pool_id)
export WEB_CLIENT_ID=$(terraform output -json client_ids | jq -r '.["web-app"]')

# Create a test user
aws cognito-idp admin-create-user \
  --user-pool-id $USER_POOL_ID \
  --username testuser@example.com \
  --user-attributes Name=email,Value=testuser@example.com Name=email_verified,Value=true \
  --temporary-password "TempPass123!@#" \
  --message-action SUPPRESS

# Add user to a group
aws cognito-idp admin-add-user-to-group \
  --user-pool-id $USER_POOL_ID \
  --username testuser@example.com \
  --group-name users

# Note: User must set up MFA before they can authenticate
# This requires the hosted UI or an application that supports MFA setup
```

## Outputs

- `user_pool_id` - ID of the Cognito User Pool
- `user_pool_arn` - ARN of the User Pool
- `user_pool_tier` - Tier of the User Pool (PLUS)
- `client_ids` - Map of app client IDs
- `user_group_names` - List of user group names
- `hosted_ui_url` - Hosted UI URL

## What's Configured

### User Pool
- Tier: **PLUS** (required for advanced security)
- Username: Email addresses
- Auto-verify: Email
- Deletion protection: **ACTIVE** (prevents accidental deletion)

### Password Policy
- Minimum length: **12 characters**
- Requires: lowercase, uppercase, numbers, symbols
- Temporary password validity: 3 days

### MFA
- Configuration: **ON** (required for all users)
- Software token: Enabled (TOTP apps like Google Authenticator)

### Advanced Security
- Mode: **ENFORCED**
- Features:
  - Compromised credential checking
  - Anomaly detection (unusual location, device)
  - IP-based rate limiting
  - Risk-based adaptive authentication

### App Clients

#### 1. web-app
- Server-side application
- Generated secret: Yes
- Token validity: 60min (access), 60min (ID), 30 days (refresh)

#### 2. mobile-app
- Mobile application
- Generated secret: No (public client)
- Token validity: 60min (access), 60min (ID), 90 days (refresh)

#### 3. admin-dashboard
- Admin dashboard
- Generated secret: Yes
- Token validity: 60min (access), 60min (ID), 1 day (refresh)
- Includes USER_PASSWORD_AUTH (for admin convenience)

### User Groups

- **admins** (precedence 1) - Administrative users
- **power-users** (precedence 5) - Power users
- **users** (precedence 10) - Regular users

### Domain
- Type: Cognito-managed domain
- Format: `{account}-{project}-{env}.auth.{region}.amazoncognito.com`

## Security Features

### 1. Required MFA
All users MUST enable MFA (software token) before they can authenticate.

### 2. Advanced Security (ENFORCED)
- Blocks compromised credentials automatically
- Detects unusual sign-in attempts
- Implements risk-based authentication challenges

### 3. Deletion Protection
User pool cannot be deleted without first setting `deletion_protection = "INACTIVE"`.

### 4. Strong Password Policy
12 character minimum with all character types required.

### 5. Prevent User Existence Errors
Prevents username enumeration attacks.

## Production Checklist

Before using in production:

- [ ] Review and adjust password policy
- [ ] Configure custom email sender (SES) for higher limits
- [ ] Set up CloudWatch alarms for failed auth attempts
- [ ] Review MFA configuration (consider SMS as backup)
- [ ] Test MFA enrollment flow
- [ ] Configure backup admin access
- [ ] Review user group structure
- [ ] Set up monitoring and logging
- [ ] Test disaster recovery procedures
- [ ] Document user onboarding process

## Important Notes

⚠️ **Deletion Protection is ACTIVE**

To delete this user pool:
1. Set `deletion_protection = "INACTIVE"` in the configuration
2. Run `terraform apply`
3. Then run `terraform destroy`

⚠️ **MFA is REQUIRED**

Users cannot authenticate without setting up MFA first. Ensure your application or hosted UI supports MFA setup.

⚠️ **Advanced Security is ENFORCED**

Failed authentication attempts may be blocked automatically. Monitor CloudWatch Logs for security events.

## Cleanup

```bash
# IMPORTANT: Set deletion_protection = "INACTIVE" first!
# Edit main.tf and change deletion_protection = "INACTIVE"
terraform apply

# Then destroy
terraform destroy
```

## Next Steps

- See `../basic` for simpler development configuration
- See `../advanced` for OAuth 2.0 and custom scopes examples

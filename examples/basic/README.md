# Basic Cognito User Pool Example

This example creates a simple AWS Cognito User Pool with email authentication, suitable for development environments.

## Features

- ✅ Email-based authentication
- ✅ ESSENTIALS tier (cost-effective)
- ✅ Optional MFA
- ✅ Basic password policy (8 characters minimum)
- ✅ Single web application client
- ✅ Hosted UI domain

## Cost Estimate

**~$0.01/month** for ESSENTIALS tier with minimal usage

- User Pool: Included in ESSENTIALS tier
- Domain: Free
- MAUs: First 50,000 are free

## Usage

### 1. Copy Variables File

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Customize Variables

Edit `terraform.tfvars`:

```hcl
account_name = "dev"
project_name = "myapp"
environment  = "development"
```

### 3. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

## Testing the User Pool

After deployment, test the configuration:

```bash
# Get the user pool ID from outputs
export USER_POOL_ID=$(terraform output -raw user_pool_id)
export CLIENT_ID=$(terraform output -json client_ids | jq -r '.["web-app"]')

# Create a test user
aws cognito-idp admin-create-user \
  --user-pool-id $USER_POOL_ID \
  --username testuser@example.com \
  --user-attributes Name=email,Value=testuser@example.com Name=email_verified,Value=true \
  --temporary-password "TempPass123!" \
  --message-action SUPPRESS

# Set permanent password
aws cognito-idp admin-set-user-password \
  --user-pool-id $USER_POOL_ID \
  --username testuser@example.com \
  --password "NewPass123!" \
  --permanent

# Test authentication
aws cognito-idp admin-initiate-auth \
  --user-pool-id $USER_POOL_ID \
  --client-id $CLIENT_ID \
  --auth-flow ADMIN_NO_SRP_AUTH \
  --auth-parameters USERNAME=testuser@example.com,PASSWORD="NewPass123!"
```

## Outputs

- `user_pool_id` - ID of the Cognito User Pool
- `user_pool_arn` - ARN of the User Pool
- `client_ids` - Map of app client IDs
- `hosted_ui_url` - Hosted UI URL for testing

## What's Configured

### User Pool
- Tier: ESSENTIALS
- Username: Email addresses
- Auto-verify: Email
- Deletion protection: INACTIVE (for easy testing)

### Password Policy
- Minimum length: 8 characters
- Requires: lowercase, uppercase, numbers

### MFA
- Configuration: OPTIONAL (users can choose)
- Software token: Enabled (TOTP apps)

### App Client
- Name: web-app
- Type: Server-side (with secret)
- Auth flows: REFRESH_TOKEN, USER_SRP

### Domain
- Type: Cognito-managed domain
- Format: `{account}-{project}-{env}.auth.{region}.amazoncognito.com`

## Cleanup

```bash
terraform destroy
```

## Next Steps

- See `../production` for production-ready configuration
- See `../advanced` for OAuth 2.0 and custom scopes

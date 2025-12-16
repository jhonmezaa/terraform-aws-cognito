# Advanced Cognito User Pool Example - OAuth 2.0

This example demonstrates advanced OAuth 2.0 configuration with resource servers, custom scopes, and multiple identity providers.

## Features

- ✅ ESSENTIALS tier
- ✅ OAuth 2.0 flows (authorization code & implicit)
- ✅ Resource servers with custom API scopes
- ✅ Multiple app clients with different OAuth configurations
- ✅ Identity provider examples (Google, Facebook - commented)
- ✅ Custom OAuth scopes (api/read, api/write, api/admin)
- ✅ Hosted UI with custom domain support
- ✅ Optional MFA

## Cost Estimate

**~$0.05/month** for ESSENTIALS tier with minimal usage

- User Pool: Included in ESSENTIALS tier
- Domain: Free (Cognito-managed)
- Custom domain: +$0.50/month (if using custom domain)

## Usage

### 1. Copy Variables File

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Customize Variables

Edit `terraform.tfvars`:

```hcl
account_name = "dev"
project_name = "oauth-app"
environment  = "development"
```

### 3. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

## Testing OAuth 2.0 Flow

After deployment:

```bash
# Get outputs
export USER_POOL_ID=$(terraform output -raw user_pool_id)
export CLIENT_ID=$(terraform output -json client_ids | jq -r '.["web-app"]')
export DOMAIN=$(terraform output -raw domain)
export REGION=$(terraform output -raw region)

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

# Test OAuth authorization URL (open in browser)
echo "https://${DOMAIN}.auth.${REGION}.amazoncognito.com/oauth2/authorize?client_id=${CLIENT_ID}&response_type=code&scope=email+openid+profile+api/read&redirect_uri=https://example.com/callback"
```

## Outputs

- `user_pool_id` - ID of the Cognito User Pool
- `user_pool_arn` - ARN of the User Pool
- `client_ids` - Map of app client IDs
- `client_secrets` - Map of app client secrets (sensitive)
- `resource_server_ids` - Map of resource server IDs
- `resource_server_scope_identifiers` - Available custom scopes
- `hosted_ui_url` - Hosted UI URL
- `oauth_authorize_url` - OAuth authorization endpoint
- `oauth_token_url` - OAuth token endpoint

## What's Configured

### User Pool
- Tier: ESSENTIALS
- Username: Email addresses
- Auto-verify: Email
- MFA: OPTIONAL

### Resource Servers

#### 1. API Resource Server (identifier: `api`)
Custom scopes:
- `api/read` - Read access to API resources
- `api/write` - Write access to API resources
- `api/admin` - Full administrative access to API

#### 2. Analytics Resource Server (identifier: `analytics`)
Custom scopes:
- `analytics/view` - View analytics data
- `analytics/export` - Export analytics data

### App Clients

#### 1. web-app
- **OAuth flows**: authorization_code, implicit
- **OAuth scopes**: email, openid, profile, api/read, api/write, api/admin
- **Callback URLs**:
  - `https://example.com/callback`
  - `http://localhost:3000/callback` (for local testing)
- **Logout URLs**:
  - `https://example.com/logout`
  - `http://localhost:3000/logout`

#### 2. mobile-app
- **OAuth flows**: authorization_code
- **OAuth scopes**: email, openid, profile, api/read
- **Callback URLs**: `myapp://callback`
- **Logout URLs**: `myapp://logout`

#### 3. admin-dashboard
- **OAuth flows**: authorization_code
- **OAuth scopes**: email, openid, profile, api/read, api/write, api/admin, analytics/view, analytics/export
- **Callback URLs**: `https://admin.example.com/callback`

### Identity Providers (Commented Examples)

The example includes commented configuration for:
- **Google**: Social login with Google
- **Facebook**: Social login with Facebook

To enable, uncomment and add your client credentials.

### Domain
- Type: Cognito-managed domain
- Format: `{account}-{project}-oauth.auth.{region}.amazoncognito.com`

## OAuth 2.0 Authorization Code Flow

### Step 1: Authorization Request

```http
GET https://{domain}.auth.{region}.amazoncognito.com/oauth2/authorize
  ?client_id={client_id}
  &response_type=code
  &scope=email+openid+profile+api/read
  &redirect_uri=https://example.com/callback
```

### Step 2: User Authenticates

User is redirected to hosted UI, enters credentials, and approves scopes.

### Step 3: Authorization Code

User is redirected back to your app with authorization code:
```
https://example.com/callback?code=AUTHORIZATION_CODE
```

### Step 4: Exchange Code for Tokens

```bash
curl -X POST https://{domain}.auth.{region}.amazoncognito.com/oauth2/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \
  -d "client_id={client_id}" \
  -d "client_secret={client_secret}" \
  -d "code=AUTHORIZATION_CODE" \
  -d "redirect_uri=https://example.com/callback"
```

### Step 5: Receive Tokens

```json
{
  "access_token": "eyJra...",
  "id_token": "eyJra...",
  "refresh_token": "eyJjd...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

## Custom Scopes in Access Tokens

When you request custom scopes (e.g., `api/read`), they appear in the access token:

```json
{
  "sub": "user-uuid",
  "cognito:groups": ["users"],
  "token_use": "access",
  "scope": "email openid profile api/read api/write",
  "auth_time": 1234567890,
  "iss": "https://cognito-idp.{region}.amazonaws.com/{user_pool_id}",
  "exp": 1234571490,
  "iat": 1234567890,
  "client_id": "client-id",
  "username": "testuser@example.com"
}
```

Your API can validate the `scope` claim to authorize requests.

## Enabling Social Login

### Google

1. Create OAuth 2.0 credentials in [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Add authorized redirect URI:
   ```
   https://{domain}.auth.{region}.amazoncognito.com/oauth2/idpresponse
   ```
3. Uncomment Google provider in `main.tf`:
   ```hcl
   identity_providers = [
     {
       provider_name = "Google"
       provider_type = "Google"
       provider_details = {
         client_id        = "your-google-client-id.apps.googleusercontent.com"
         client_secret    = "your-google-client-secret"
         authorize_scopes = "email profile openid"
       }
       attribute_mapping = {
         email    = "email"
         username = "sub"
         name     = "name"
       }
     }
   ]
   ```
4. Update `supported_identity_providers` in app clients:
   ```hcl
   supported_identity_providers = ["COGNITO", "Google"]
   ```

### Facebook

Similar process:
1. Create Facebook App at [developers.facebook.com](https://developers.facebook.com)
2. Add OAuth redirect URI
3. Uncomment Facebook provider configuration

## API Gateway Integration

Example API Gateway Cognito Authorizer:

```hcl
resource "aws_api_gateway_authorizer" "cognito" {
  name            = "cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.api.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [module.cognito.user_pool_arn]

  # Validate custom scopes
  identity_source = "method.request.header.Authorization"
}

resource "aws_api_gateway_method" "protected" {
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.cognito.id
  authorization_scopes = ["api/read"]  # Require api/read scope
  # ...
}
```

## Testing Custom Scopes

```bash
# 1. Get access token with custom scope
# (Use OAuth flow above)

# 2. Decode access token to verify scopes
# Use jwt.io or:
echo $ACCESS_TOKEN | cut -d. -f2 | base64 -d | jq .

# 3. Call API with access token
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
  https://api.example.com/resource
```

## Best Practices

### OAuth Scopes
- ✅ Request minimum scopes needed
- ✅ Use custom scopes for API authorization
- ✅ Validate scopes in your API backend
- ✅ Document available scopes for API consumers

### Security
- ✅ Use authorization code flow for server-side apps (most secure)
- ✅ Use PKCE for public clients (mobile, SPA)
- ✅ Keep client secrets secure
- ✅ Use HTTPS for all redirect URIs
- ✅ Validate redirect URIs server-side

### Token Management
- ✅ Short access tokens (60 minutes)
- ✅ Longer refresh tokens (30-90 days)
- ✅ Rotate refresh tokens on use
- ✅ Enable token revocation

## Cleanup

```bash
terraform destroy
```

## Next Steps

- See `../basic` for simpler configuration
- See `../production` for production-ready security
- Check main README.md for integration examples

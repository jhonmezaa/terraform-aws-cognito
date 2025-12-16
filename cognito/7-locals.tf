# Local values
locals {
  # Region prefix mapping for consistent naming
  region_prefix_map = {
    "us-east-1"      = "ause1"
    "us-east-2"      = "ause2"
    "us-west-1"      = "usw1"
    "us-west-2"      = "usw2"
    "ca-central-1"   = "cac1"
    "eu-west-1"      = "euw1"
    "eu-west-2"      = "euw2"
    "eu-west-3"      = "euw3"
    "eu-central-1"   = "euc1"
    "eu-central-2"   = "euc2"
    "eu-north-1"     = "eun1"
    "eu-south-1"     = "eus1"
    "eu-south-2"     = "eus2"
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-northeast-3" = "apne3"
    "ap-southeast-1" = "apse1"
    "ap-southeast-2" = "apse2"
    "ap-southeast-3" = "apse3"
    "ap-southeast-4" = "apse4"
    "ap-south-1"     = "aps1"
    "ap-south-2"     = "aps2"
    "sa-east-1"      = "sae1"
    "me-south-1"     = "mes1"
    "me-central-1"   = "mec1"
    "af-south-1"     = "afs1"
  }

  # Region prefix (use variable if provided, otherwise lookup from map)
  region_prefix = var.region_prefix != null ? var.region_prefix : lookup(
    local.region_prefix_map,
    data.aws_region.current.id,
    "custom"
  )

  # User pool name with naming convention
  user_pool_name = "${local.region_prefix}-cognito-${var.account_name}-${var.project_name}"

  # Common tags
  common_tags = merge(
    {
      ManagedBy   = "Terraform"
      Module      = "terraform-aws-cognito"
      Region      = data.aws_region.current.id
      Account     = var.account_name
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )

  # Lambda config enabled check
  enable_lambda_config = (
    var.lambda_config_create_auth_challenge != null ||
    var.lambda_config_custom_message != null ||
    var.lambda_config_define_auth_challenge != null ||
    var.lambda_config_post_authentication != null ||
    var.lambda_config_post_confirmation != null ||
    var.lambda_config_pre_authentication != null ||
    var.lambda_config_pre_sign_up != null ||
    var.lambda_config_pre_token_generation != null ||
    var.lambda_config_user_migration != null ||
    var.lambda_config_verify_auth_challenge_response != null ||
    var.lambda_config_custom_email_sender_lambda_arn != null ||
    var.lambda_config_custom_sms_sender_lambda_arn != null ||
    var.lambda_config_pre_token_generation_config_lambda_arn != null
  )
}

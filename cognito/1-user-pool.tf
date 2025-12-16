# AWS Cognito User Pool
resource "aws_cognito_user_pool" "this" {
  name = local.user_pool_name

  # User Pool Tier (LITE, ESSENTIALS, PLUS)
  user_pool_tier = var.user_pool_tier

  # Email/Username Configuration
  # NOTE: alias_attributes and username_attributes are mutually exclusive
  alias_attributes         = length(var.username_attributes) == 0 ? var.alias_attributes : null
  username_attributes      = length(var.username_attributes) > 0 ? var.username_attributes : null
  auto_verified_attributes = var.auto_verified_attributes

  # Username Configuration
  dynamic "username_configuration" {
    for_each = var.case_sensitive ? [1] : []
    content {
      case_sensitive = var.case_sensitive
    }
  }

  # MFA Configuration
  mfa_configuration = var.mfa_configuration

  dynamic "software_token_mfa_configuration" {
    for_each = contains(["ON", "OPTIONAL"], var.mfa_configuration) ? [1] : []
    content {
      enabled = true
    }
  }

  # Password Policy
  password_policy {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = var.password_require_lowercase
    require_uppercase                = var.password_require_uppercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  # Sign-in Policy
  dynamic "sign_in_policy" {
    for_each = length(var.sign_in_policy_allowed_first_auth_factors) > 0 ? [1] : []
    content {
      allowed_first_auth_factors = var.sign_in_policy_allowed_first_auth_factors
    }
  }

  # User Attribute Update Settings
  dynamic "user_attribute_update_settings" {
    for_each = length(var.attributes_require_verification_before_update) > 0 ? [1] : []
    content {
      attributes_require_verification_before_update = var.attributes_require_verification_before_update
    }
  }

  # Account Recovery
  dynamic "account_recovery_setting" {
    for_each = length(var.recovery_mechanisms) > 0 ? [1] : []
    content {
      dynamic "recovery_mechanism" {
        for_each = var.recovery_mechanisms
        content {
          name     = recovery_mechanism.value.name
          priority = recovery_mechanism.value.priority
        }
      }
    }
  }

  # Admin Create User Config
  admin_create_user_config {
    allow_admin_create_user_only = var.admin_create_user_config_allow_admin_create_user_only

    dynamic "invite_message_template" {
      for_each = var.admin_create_user_config_email_message != null ? [1] : []
      content {
        email_message = var.admin_create_user_config_email_message
        email_subject = var.admin_create_user_config_email_subject
        sms_message   = var.admin_create_user_config_sms_message
      }
    }
  }

  # Device Configuration
  dynamic "device_configuration" {
    for_each = var.device_configuration_challenge_required_on_new_device != null ? [1] : []
    content {
      challenge_required_on_new_device      = var.device_configuration_challenge_required_on_new_device
      device_only_remembered_on_user_prompt = var.device_configuration_device_only_remembered_on_user_prompt
    }
  }

  # Email Configuration
  dynamic "email_configuration" {
    for_each = var.email_configuration_source_arn != null || var.email_configuration_email_sending_account != null ? [1] : []
    content {
      source_arn             = var.email_configuration_source_arn
      from_email_address     = var.email_configuration_from_email_address
      reply_to_email_address = var.email_configuration_reply_to_email_address
      email_sending_account  = var.email_configuration_email_sending_account
      configuration_set      = var.email_configuration_configuration_set
    }
  }

  # SMS Configuration
  dynamic "sms_configuration" {
    for_each = var.sms_configuration_external_id != null ? [1] : []
    content {
      external_id    = var.sms_configuration_external_id
      sns_caller_arn = var.sms_configuration_sns_caller_arn
      sns_region     = var.sms_configuration_sns_region
    }
  }

  # Lambda Config
  dynamic "lambda_config" {
    for_each = local.enable_lambda_config ? [1] : []
    content {
      create_auth_challenge          = var.lambda_config_create_auth_challenge
      custom_message                 = var.lambda_config_custom_message
      define_auth_challenge          = var.lambda_config_define_auth_challenge
      post_authentication            = var.lambda_config_post_authentication
      post_confirmation              = var.lambda_config_post_confirmation
      pre_authentication             = var.lambda_config_pre_authentication
      pre_sign_up                    = var.lambda_config_pre_sign_up
      pre_token_generation           = var.lambda_config_pre_token_generation
      user_migration                 = var.lambda_config_user_migration
      verify_auth_challenge_response = var.lambda_config_verify_auth_challenge_response

      dynamic "custom_email_sender" {
        for_each = var.lambda_config_custom_email_sender_lambda_arn != null ? [1] : []
        content {
          lambda_arn     = var.lambda_config_custom_email_sender_lambda_arn
          lambda_version = var.lambda_config_custom_email_sender_lambda_version
        }
      }

      dynamic "custom_sms_sender" {
        for_each = var.lambda_config_custom_sms_sender_lambda_arn != null ? [1] : []
        content {
          lambda_arn     = var.lambda_config_custom_sms_sender_lambda_arn
          lambda_version = var.lambda_config_custom_sms_sender_lambda_version
        }
      }

      kms_key_id = var.lambda_config_kms_key_id

      dynamic "pre_token_generation_config" {
        for_each = var.lambda_config_pre_token_generation_config_lambda_arn != null ? [1] : []
        content {
          lambda_arn     = var.lambda_config_pre_token_generation_config_lambda_arn
          lambda_version = var.lambda_config_pre_token_generation_config_lambda_version
        }
      }
    }
  }

  # Custom Schemas
  dynamic "schema" {
    for_each = var.schemas
    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      developer_only_attribute = lookup(schema.value, "developer_only_attribute", false)
      mutable                  = lookup(schema.value, "mutable", true)
      required                 = lookup(schema.value, "required", false)

      dynamic "number_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "Number" ? [1] : []
        content {
          min_value = lookup(schema.value, "min_value", null)
          max_value = lookup(schema.value, "max_value", null)
        }
      }

      dynamic "string_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "String" || schema.value.attribute_data_type == "DateTime" ? [1] : []
        content {
          min_length = lookup(schema.value, "min_length", 0)
          max_length = lookup(schema.value, "max_length", 2048)
        }
      }
    }
  }

  # Advanced Security
  dynamic "user_pool_add_ons" {
    for_each = var.enable_advanced_security ? [1] : []
    content {
      advanced_security_mode = var.advanced_security_mode
    }
  }

  # Verification Message Template
  dynamic "verification_message_template" {
    for_each = var.verification_message_template_default_email_option != null ? [1] : []
    content {
      default_email_option  = var.verification_message_template_default_email_option
      email_message         = var.verification_message_template_email_message
      email_message_by_link = var.verification_message_template_email_message_by_link
      email_subject         = var.verification_message_template_email_subject
      email_subject_by_link = var.verification_message_template_email_subject_by_link
      sms_message           = var.verification_message_template_sms_message
    }
  }

  # Deletion Protection
  deletion_protection = var.deletion_protection

  # Tags
  tags = merge(
    local.common_tags,
    var.user_pool_tags,
    {
      Name = local.user_pool_name
    }
  )
}

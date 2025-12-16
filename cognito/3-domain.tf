# Cognito Domain for Hosted UI
resource "aws_cognito_user_pool_domain" "this" {
  count = var.domain != null ? 1 : 0

  domain          = var.domain
  certificate_arn = var.domain_certificate_arn
  user_pool_id    = aws_cognito_user_pool.this.id
}

# Custom Domain (if certificate provided)
resource "aws_cognito_user_pool_domain" "custom" {
  count = var.custom_domain != null ? 1 : 0

  domain          = var.custom_domain
  certificate_arn = var.custom_domain_certificate_arn
  user_pool_id    = aws_cognito_user_pool.this.id
}

# UI Customization
resource "aws_cognito_user_pool_ui_customization" "this" {
  count = var.ui_customization_css != null || var.ui_customization_image_file != null ? 1 : 0

  client_id = var.ui_customization_client_id

  css        = var.ui_customization_css
  image_file = var.ui_customization_image_file != null ? filebase64(var.ui_customization_image_file) : null

  user_pool_id = aws_cognito_user_pool.this.id

  depends_on = [
    aws_cognito_user_pool_domain.this,
    aws_cognito_user_pool_domain.custom
  ]
}

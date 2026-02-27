resource "aws_wafv2_web_acl_association" "cognito_user_pool" {
  count = var.waf_web_acl_arn == null ? 0 : 1

  resource_arn = aws_cognito_user_pool.this.arn
  web_acl_arn  = var.waf_web_acl_arn
}

# Validado con un CNAME en Cloudflare (DNS only). Ese registro debe quedarse para que ACM renueve el certificado.
resource "aws_acm_certificate" "chat" {
  domain_name       = var.app_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

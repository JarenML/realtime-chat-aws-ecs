# Validado con un CNAME en Cloudflare (DNS only). Ese registro debe quedarse para que ACM renueve el certificado.
resource "aws_acm_certificate" "chat" {
  domain_name       = var.app_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Espera a que el certificado quede "Issued" (despues de crear el CNAME de validacion en Cloudflare)
# antes de crear el listener HTTPS.
resource "aws_acm_certificate_validation" "chat" {
  certificate_arn = aws_acm_certificate.chat.arn

  timeouts {
    create = "45m"
  }
}

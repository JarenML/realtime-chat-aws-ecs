# Creado a mano y validado con un CNAME en Cloudflare: se adopta tal cual en vez de pedir uno nuevo.
import {
  to = aws_acm_certificate.chat
  id = "arn:aws:acm:us-east-1:574548986505:certificate/0ef8ef08-a95d-48ef-85c4-19b9c334e578"
}

resource "aws_acm_certificate" "chat" {
  domain_name       = var.app_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

output "app_url" {
  value = "https://${var.app_domain}"
}

output "acm_validation_records" {
  description = "CNAME para validar el certificado en Cloudflare (DNS only). No borrarlo: ACM lo usa para renovar."
  value = [for o in aws_acm_certificate.chat.domain_validation_options : {
    name  = o.resource_record_name
    type  = o.resource_record_type
    value = o.resource_record_value
  }]
}

output "alb_dns_name" {
  description = "Destino del CNAME del chat en Cloudflare."
  value       = aws_lb.main.dns_name
}

output "ecr_frontend_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "ecs_cluster" {
  value = aws_ecs_cluster.main.name
}

output "redis_primary_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}

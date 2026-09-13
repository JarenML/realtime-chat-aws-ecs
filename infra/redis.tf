resource "aws_elasticache_subnet_group" "redis" {
  name        = "ws-redis-subnet-group"
  description = "Subnet group para practica ElastiCache"
  subnet_ids  = data.aws_subnets.default.ids
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id        = "ws-redis-demo"
  description                 = "idk"
  engine                      = "redis"
  engine_version              = "7.1"
  node_type                   = "cache.t4g.micro"
  num_cache_clusters          = 1
  preferred_cache_cluster_azs = ["us-east-1d"]
  port                        = 6379
  parameter_group_name        = "default.redis7"
  subnet_group_name           = aws_elasticache_subnet_group.redis.name
  security_group_ids          = [aws_security_group.elasticache.id]
  automatic_failover_enabled  = false
  multi_az_enabled            = false
  transit_encryption_enabled  = true
  transit_encryption_mode     = "required"
  at_rest_encryption_enabled  = true
  auto_minor_version_upgrade  = true
  snapshot_retention_limit    = 1
  snapshot_window             = "06:30-07:30"
  maintenance_window          = "fri:05:30-fri:06:30"
  network_type                = "ipv4"
  ip_discovery                = "ipv4"
  apply_immediately           = true

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.elasticache.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }
}

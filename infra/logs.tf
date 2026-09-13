resource "aws_cloudwatch_log_group" "ecs_frontend" {
  name = "/ecs/ws-redis-frontend"
}

resource "aws_cloudwatch_log_group" "ecs_backend" {
  name = "/ecs/ws-redis-backend"
}

resource "aws_cloudwatch_log_group" "elasticache" {
  name = "/elasticache/ws-redis-demo"
}

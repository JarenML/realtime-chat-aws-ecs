# force_delete: permite terraform destroy aunque el repositorio tenga imagenes.
resource "aws_ecr_repository" "frontend" {
  name                 = "ws-redis-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "ws-redis-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "backend_url" {
  description = "IP publica y puerto de la tarea del backend (ej: 50.17.49.116:8000). Solo se conoce despues de que la tarea arranca."
  type        = string
  default     = ""
}

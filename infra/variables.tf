variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "app_domain" {
  description = "Dominio publico del chat. Debe coincidir con el certificado de ACM y con el CNAME en Cloudflare."
  type        = string
  default     = "chat.jarenramos.com"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

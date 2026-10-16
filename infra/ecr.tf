resource "aws_ecr_repository" "modaviva_api" {
  name                 = "modaviva-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}
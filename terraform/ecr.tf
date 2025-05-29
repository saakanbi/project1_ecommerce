resource "aws_ecr_repository" "ecommerce_backend" {
  name                 = "ecommerce-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "ecommerce-backend"
    Environment = "dev"
  }
}

# ECR Lifecycle Policy - keep only the last 10 images
resource "aws_ecr_lifecycle_policy" "ecommerce_backend_policy" {
  repository = aws_ecr_repository.ecommerce_backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
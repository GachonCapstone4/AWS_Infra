resource "aws_ecr_repository" "capstone_ecr" {
 name = "capstone/ecr"

  tags = {
    Name = "capstone-ecr"
  }
}

resource "aws_ecr_lifecycle_policy" "capstone_ecr_policy" {
  repository = aws_ecr_repository.capstone_ecr.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 4 images, delete older ones"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 4
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

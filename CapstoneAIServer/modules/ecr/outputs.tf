output "ecr_repository_url" {
  value       = aws_ecr_repository.capstone_ecr.repository_url
  description = "The URL of the ECR repository"
}

output "ecr_repository_arn" {
  value       = aws_ecr_repository.capstone_ecr.arn
  description = "The ARN of the ECR repository"
}

output "ecr_repository_name" {
  value       = aws_ecr_repository.capstone_ecr.name
  description = "The name of the ECR repository"
}

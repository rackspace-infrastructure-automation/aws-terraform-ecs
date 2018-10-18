output "ecr_repository_name" {
  value       = "${element(coalescelist(aws_ecr_repository.ecr_repo.*.name, list("")), 0)}"
  description = "Name of the ECR repository"
}

output "ecr_repository_registry_id" {
  value       = "${element(coalescelist(aws_ecr_repository.ecr_repo.*.registry_id, list("")), 0)}"
  description = "Name of the ECR repository"
}

output "ecr_repository_registry_url" {
  value       = "${element(coalescelist(aws_ecr_repository.ecr_repo.*.repository_url, list("")), 0)}"
  description = "URL of the ECR repository"
}

output "ecr_repository_name" {
  value       = "${element(coalescelist(aws_ecr_repository.ecr_repo.*.name, list("")), 0)}"
  description = "Name of the ECR repository"
}

output "ecr_repository_registry_id" {
  value       = "${element(coalescelist(aws_ecr_repository.ecr_repo.*.registry_id, list("")), 0)}"
  description = "Name of the ECR repository"
}

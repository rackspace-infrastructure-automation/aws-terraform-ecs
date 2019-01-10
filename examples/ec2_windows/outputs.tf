output "ecr_repository_name" {
  value       = "${module.ecr_repo.ecr_repository_name}"
  description = "Name of the ECR repository"
}

output "ecr_repository_registry_id" {
  value       = "${module.ecr_repo.ecr_repository_registry_id}"
  description = "Name of the ECR repository"
}

output "ecr_repository_registry_url" {
  value       = "${module.ecr_repo.ecr_repository_registry_url}"
  description = "URL of the ECR repository"
}

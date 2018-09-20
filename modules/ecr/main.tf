resource "aws_ecr_repository" "ecr_repo" {
  count = "${var.provision_ecr ? 1 : 0}"
  name  = "${var.ecr_repository_name}"
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  count      = "${var.provision_ecr && var.ecr_lifecycle_policy_text != "" ? 1 : 0}"
  policy     = "${var.ecr_lifecycle_policy_text}"
  repository = "${aws_ecr_repository.ecr_repo.name}"
}

resource "aws_ecr_repository_policy" "ecr_repo_policy" {
  count      = "${var.provision_ecr && var.ecr_repository_policy_text != "" ? 1 : 0}"
  policy     = "${var.ecr_repository_policy_text}"
  repository = "${aws_ecr_repository.ecr_repo.name}"
}

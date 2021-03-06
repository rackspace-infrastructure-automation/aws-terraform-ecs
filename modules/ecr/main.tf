/**
* # aws-terraform-ecs/modules/ecr
*
* This submodule creates an ecr repo.
*
* ## Basic Usage
*
* ```
* module "ecr_repo" {
*   source              = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs/modules/ecr?ref=v0.12.0"
*   provision_ecr       = true
*   name                = "myrepo-${random_string.ecs_rstring.result}"
* }
*```
*
* Full working references are available at [examples](examples)
*/

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.7.0"
  }
}

resource "aws_ecr_repository" "ecr_repo" {
  count = var.provision_ecr ? 1 : 0

  name = var.name
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  count = var.provision_ecr && var.ecr_lifecycle_policy_text != "" ? 1 : 0

  policy     = var.ecr_lifecycle_policy_text
  repository = aws_ecr_repository.ecr_repo[0].name
}

resource "aws_ecr_repository_policy" "ecr_repo_policy" {
  count = var.provision_ecr && var.ecr_repository_policy_text != "" ? 1 : 0

  policy     = var.ecr_repository_policy_text
  repository = aws_ecr_repository.ecr_repo[0].name
}


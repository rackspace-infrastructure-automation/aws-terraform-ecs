provider "aws" {
  region  = "us-west-2"
  version = "~> 3.0"
}

resource "random_string" "ecs_rstring" {
  length  = 18
  special = false
  upper   = false
}

module "ecr_no_repo" {
  source = "../../module/modules/ecr"

  name          = "no_repo-${random_string.ecs_rstring.result}"
  provision_ecr = false

}

data "aws_iam_policy_document" "ecr_repo_policy" {
  statement {
    sid    = "new policy"
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

locals {
  ecr_lifecycle_policy = {
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  }
}

module "ecr_repo" {
  source = "../../module/modules/ecr"

  ecr_lifecycle_policy_text  = jsonencode(local.ecr_lifecycle_policy)
  ecr_repository_policy_text = data.aws_iam_policy_document.ecr_repo_policy.json
  name                       = "myrepo-${random_string.ecs_rstring.result}"
  provision_ecr              = true
}

provider "aws" {
  version = ">= 2.1.0"
  region  = "us-west-2"
}

resource "random_string" "ecs_rstring" {
  length  = 18
  upper   = false
  special = false
}

module "ecr_repo" {
  source              = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/ecr/?ref=v0.0.3"
  provision_ecr       = true
  ecr_repository_name = "myrepo-${random_string.ecs_rstring.result}"

  ecr_lifecycle_policy_text = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF


  ecr_repository_policy_text = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
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
        }
    ]
}
EOF

}


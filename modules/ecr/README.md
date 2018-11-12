## Basic Usage
```
module "ecr_repo" {
  source              = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs/modules/ecr?ref=v0.0.1"
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
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ecr_lifecycle_policy_text | The JSON repository policy text to apply to the repository. The length must be between 100 and 10,240 characters. | string | `` | no |
| ecr_repository_name | A name for the image repository | string | `` | no |
| ecr_repository_policy_text | A JSON policy that controls who has access to the repository and which actions they can perform on it. | string | `` | no |
| provision_ecr | Provision ECR resource? true or false | string | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecr_repository_name | Name of the ECR repository |
| ecr_repository_registry_id | Name of the ECR repository |
| ecr_repository_registry_url | URL of the ECR repository |

terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 3.0"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.12.4"

  name = "${var.ecs_cluster_name}-VPC"
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow inbound web traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 80
    to_port   = 80

    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  ingress {
    from_port = 22
    to_port   = 22

    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
}

module "ecs_cluster" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/cluster/?ref=v0.12.2"

  name = var.ecs_cluster_name
}

data "aws_region" "current_region" {
}

data "aws_caller_identity" "current" {
}

data "template_file" "ec2ecs_sample_app" {
  template = file("ec2ecs-sample-app.json")

  vars = {
    AWS_REGION = var.aws_region
    LOGS_GROUP = aws_cloudwatch_log_group.ec2ecs_sample_app.name
  }
}

data "aws_iam_policy_document" "ecs_role_task_assume" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_role_task_assume" {
  name = "${var.ecs_cluster_name}_task_assume"

  assume_role_policy = data.aws_iam_policy_document.ecs_role_task_assume.json
}

data "aws_iam_policy_document" "ecs_task_assume_policy" {

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_assume_policy" {
  name = "ecsec2_task_assume_policy"
  role = aws_iam_role.ecs_role_task_assume.id

  policy = data.aws_iam_policy_document.ecs_task_assume_policy.json
}

resource "aws_cloudwatch_log_group" "ec2ecs_sample_app" {
  name              = "/ecs/${var.ecs_cluster_name}"
  retention_in_days = 30

  tags = {
    Name = "ec2ecs-sample-app"
  }
}

resource "random_string" "password" {
  length      = 16
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
  special     = false
}

resource "random_string" "sqs_rstring" {
  length  = 18
  upper   = false
  special = false
}

resource "aws_sqs_queue" "ec2_asg_test_sqs" {
  name = "${random_string.sqs_rstring.result}-my-example-queue"
}

module "sns_sqs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=v0.12.2"

  name = "${random_string.sqs_rstring.result}-ec2-asg-test-topic"

  create_subscription_1 = true
  endpoint_1            = aws_sqs_queue.ec2_asg_test_sqs.arn
  protocol_1            = "sqs"
}

data "aws_ami" "amazon_ecs" {
  most_recent = true
  owners      = ["591542846629"]

  filter {
    name   = "name"
    values = ["amzn-ami-2018.03.*-amazon-ecs-optimized"]
  }
}

module "ec2_asg" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_asg?ref=v0.12.9"

  asg_count = 1
  ec2_os    = "amazon"

  cw_low_operator     = "LessThanThreshold"
  load_balancer_names = [""]

  instance_role_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access",
  ]

  backup_tag_value                       = "False"
  cloudwatch_log_retention               = 30
  cw_high_period                         = 60
  cw_low_period                          = 300
  cw_scaling_metric                      = "CPUUtilization"
  ec2_scale_down_adjustment              = 1
  ec2_scale_down_cool_down               = 60
  enable_ebs_optimization                = false
  enable_scaling_notification            = true
  environment                            = var.environment
  image_id                               = data.aws_ami.amazon_ecs.image_id
  instance_type                          = "t2.small"
  key_pair                               = var.ec2_keypair
  instance_role_managed_policy_arn_count = 3
  scaling_min                            = 1
  ssm_association_refresh_rate           = "rate(1 day)"
  subnets                                = [element(module.vpc.public_subnets, 0), element(module.vpc.public_subnets, 1)]
  tenancy                                = "default"

  # If ALB target groups are being used, one can specify ARNs like the commented line below.
  #target_group_arns                      = ["${aws_lb_target_group.my_tg.arn}"]

  cw_high_evaluations           = 3
  cw_high_operator              = "GreaterThanThreshold"
  cw_high_threshold             = 60
  cw_low_evaluations            = 3
  cw_low_threshold              = 30
  detailed_monitoring           = true
  ec2_scale_up_adjustment       = 1
  ec2_scale_up_cool_down        = 60
  health_check_grace_period     = 300
  health_check_type             = "EC2"
  initial_userdata_commands     = module.ecs_cluster.cluster_join_command_linux
  install_codedeploy_agent      = false
  name                          = "${var.ecs_cluster_name}-ASG"
  perform_ssm_inventory_tag     = "True"
  primary_ebs_volume_iops       = 0
  primary_ebs_volume_size       = 20
  primary_ebs_volume_type       = "gp2"
  scaling_max                   = 2
  scaling_notification_topic    = module.sns_sqs.topic_arn
  security_groups               = [module.vpc.default_sg, aws_security_group.allow_web.id]
  ssm_patching_group            = "MyPatchGroup1"
  terminated_instances          = 30
  asg_wait_for_capacity_timeout = "10m"
}

resource "aws_ecs_task_definition" "ecs_task_def" {
  container_definitions    = data.template_file.ec2ecs_sample_app.rendered
  execution_role_arn       = aws_iam_role.ecs_role_task_assume.arn
  family                   = lower(var.task_name)
  network_mode             = var.network_mode
  requires_compatibilities = ["EC2"]
}

resource "aws_ecs_service" "ecs_service_def" {
  cluster         = module.ecs_cluster.cluster_id
  desired_count   = var.ecs_service_desired_count
  name            = lower(var.service_name)
  task_definition = aws_ecs_task_definition.ecs_task_def.arn
}

## ECR Provisioning

resource "random_string" "ecr_rstring" {
  length  = 18
  upper   = false
  special = false
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
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/ecr/?ref=v0.12.2"

  name                       = "myrepo-${random_string.ecr_rstring.result}"
  provision_ecr              = true
  ecr_lifecycle_policy_text  = jsonencode(local.ecr_lifecycle_policy)
  ecr_repository_policy_text = data.aws_iam_policy_document.ecr_repo_policy.json

}

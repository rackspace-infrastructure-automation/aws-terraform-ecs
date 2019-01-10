# providers

provider "aws" {
  version = "~> 1.2"

  #access_key = "${var.aws_access_key}"
  #secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

# locals

locals {
  tags = {
    Environment = "${var.environment}"
    Terraform   = "true"
  }
}

# data objects

data "aws_ami" "windows_ecs" {
  most_recent = true
  owners      = ["591542846629"]

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-ECS_Optimized-*"]
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecr_repository_policy_text" {
  version = "2008-10-17"

  statement {
    sid = "new policy"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchDeleteImage",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DeleteRepository",
      "ecr:DeleteRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:SetRepositoryPolicy",
      "ecr:UploadLayerPart",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_region" "current_region" {}

data "template_file" "ecr_lifecycle_policy_text" {
  template = "${file("ecr_lifecycle_policy_text.json")}"
}

data "template_file" "ecs_ec2_sample_app" {
  template = "${file("ecs-ec2-sample-app.json")}"

  vars {
    AWS_REGION = "${var.aws_region}"
    LOGS_GROUP = "${aws_cloudwatch_log_group.ecs_ec2_sample_app.name}"
  }
}

# resources

resource "aws_cloudwatch_log_group" "ecs_ec2_sample_app" {
  name              = "/ecs/ecs-ec2-sample-app"
  retention_in_days = 30

  tags = "${
    merge(
      local.tags,
      map(
        "Name", "ecs-ec2-sample-app"
      )
    )
  }"
}

resource "aws_iam_role" "ecs_task" {
  name = "ecs_ec2_task_assume"

  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_assume.json}"
}

resource "aws_iam_role_policy" "ecs_task" {
  name = "ecs_ec2_task_assume_policy"
  role = "${aws_iam_role.ecs_task.id}"

  policy = "${data.aws_iam_policy_document.ecs_task.json}"
}

resource "aws_ecs_service" "ecs_service_def" {
  name            = "${lower(var.service_name)}"
  cluster         = "${module.ecs_cluster.cluster_id}"
  task_definition = "${aws_ecs_task_definition.ecs_task_def.arn}"
  desired_count   = "${var.ecs_service_desired_count}"
}

resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = "${lower(var.task_name)}"
  container_definitions    = "${data.template_file.ecs_ec2_sample_app.rendered}"
  execution_role_arn       = "${aws_iam_role.ecs_task.arn}"
  requires_compatibilities = ["EC2"]
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow inbound web traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${local.tags}"
}

resource "aws_sqs_queue" "ec2_asg_test" {
  name = "${random_string.sqs.result}-my-example-queue"
}

resource "random_string" "ecr" {
  length  = 18
  upper   = false
  special = false
}

resource "random_string" "password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "random_string" "sqs" {
  length  = 18
  upper   = false
  special = false
}

# modules

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.6"

  custom_tags = "${local.tags}"
  vpc_name    = "ECS-EC2-Example-VPC"
}

module "ecr_repo" {
  source              = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/ecr/?ref=v0.0.2"
  provision_ecr       = true
  ecr_repository_name = "myrepo-${random_string.ecr.result}"

  ecr_lifecycle_policy_text = "${data.template_file.ecr_lifecycle_policy_text.rendered}"

  ecr_repository_policy_text = "${data.aws_iam_policy_document.ecr_repository_policy_text.json}"
}

module "ecs_cluster" {
  #source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/cluster/?ref=ecs-windows"

  source = "../../modules/cluster"

  cluster_name = "${var.ecs_cluster_name}"
  tags         = "${local.tags}"
}

module "ec2_asg" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_asg?ref=v0.0.8"

  ec2_os                      = "windows2016"
  enable_scaling_notification = true
  environment                 = "${var.environment}"
  image_id                    = "${data.aws_ami.windows_ecs.image_id}"

  # required for Windows AMIs pre 2018.11
  initial_userdata_commands = <<EOF
${module.ecs_cluster.cluster_join_command_windows}

$startDir = (Get-Location).Path

$dir = $env:TEMP + "\ssm"
New-Item -ItemType directory -Path $dir -Force
Set-Location $dir
Invoke-WebRequest -Uri https://amazon-ssm-${var.aws_region}.s3.amazonaws.com/latest/windows_amd64/AmazonSSMAgentSetup.exe -OutFile AmazonSSMAgentSetup.exe
Start-Process .\AmazonSSMAgentSetup.exe -ArgumentList @("/q", "/log", "install.log") -Wait

Set-Location $startDir
EOF

  instance_role_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access",
  ]

  instance_role_managed_policy_arn_count = "3"
  instance_type                          = "t2.xlarge"
  key_pair                               = "${var.ec2_keypair}"
  primary_ebs_volume_size                = "50"
  resource_name                          = "ECS-Cluster-ASG"
  scaling_max                            = "2"
  scaling_min                            = "1"
  scaling_notification_topic             = "${module.sns_sqs.topic_arn}"

  security_group_list = [
    "${module.vpc.default_sg}",
    "${aws_security_group.allow_web.id}",
  ]

  ssm_patching_group = "MyPatchGroup1"
  subnets            = "${module.vpc.public_subnets}"

  # If ALB target groups are being used, one can specify ARNs like the commented line below.
  # target_group_arns = ["${aws_lb_target_group.my_tg.arn}"]
}

module "sns_sqs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=v0.0.2"

  create_subscription_1 = true
  endpoint_1            = "${aws_sqs_queue.ec2_asg_test.arn}"
  protocol_1            = "sqs"
  topic_name            = "${random_string.sqs.result}-ec2-asg-test-topic"
}

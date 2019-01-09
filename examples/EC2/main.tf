provider "aws" {
  version    = "~> 1.2"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.2"

  vpc_name = "ECS-EC2-Example-VPC"
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow inbound web traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ecs_cluster" {
  source           = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/cluster/?ref=v0.0.2"
  ecs_cluster_name = "${var.ecs_cluster_name}"
}

data "aws_region" "current_region" {}
data "aws_caller_identity" "current" {}

data "template_file" "ec2ecs-sample-app" {
  template = "${file("ec2ecs-sample-app.json")}"

  vars {
    AWS_REGION = "${var.aws_region}"
    LOGS_GROUP = "${aws_cloudwatch_log_group.ec2ecs-sample-app.name}"
  }
}

resource "aws_iam_role" "ecs_role_task_assume" {
  name = "ecsec2_task_assume"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_task_assume_policy" {
  name = "ecsec2_task_assume_policy"
  role = "${aws_iam_role.ecs_role_task_assume.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_cloudwatch_log_group" "ec2ecs-sample-app" {
  name              = "/ecs/ec2ecs-sample-app"
  retention_in_days = 30

  tags {
    Name = "ec2ecs-sample-app"
  }
}

resource "random_string" "password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "random_string" "sqs_rstring" {
  length  = 18
  upper   = false
  special = false
}

resource "aws_sqs_queue" "ec2-asg-test_sqs" {
  name = "${random_string.sqs_rstring.result}-my-example-queue"
}

module "sns_sqs" {
  source     = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=v0.0.2"
  topic_name = "${random_string.sqs_rstring.result}-ec2-asg-test-topic"

  create_subscription_1 = true
  protocol_1            = "sqs"
  endpoint_1            = "${aws_sqs_queue.ec2-asg-test_sqs.arn}"
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
  source    = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_asg?ref=v0.0.6"
  ec2_os    = "amazon"
  asg_count = "1"

  load_balancer_names = [""]
  cw_low_operator     = "LessThanThreshold"

  instance_role_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access",
  ]

  instance_role_managed_policy_arn_count = "3"
  environment                            = "${var.environment}"
  ssm_association_refresh_rate           = "rate(1 day)"
  cw_scaling_metric                      = "CPUUtilization"
  enable_ebs_optimization                = "False"
  scaling_min                            = "1"
  cloudwatch_log_retention               = "30"
  cw_high_period                         = "60"
  enable_scaling_notification            = true
  subnets                                = ["${element(module.vpc.public_subnets, 0)}", "${element(module.vpc.public_subnets, 1)}"]
  ec2_scale_down_adjustment              = "1"
  image_id                               = "${data.aws_ami.amazon_ecs.image_id}"
  cw_low_period                          = "300"
  key_pair                               = "${var.ec2_keypair}"
  tenancy                                = "default"
  backup_tag_value                       = "False"
  ec2_scale_down_cool_down               = "60"
  instance_type                          = "t2.small"

  # If ALB target groups are being used, one can specify ARNs like the commented line below.
  #target_group_arns                      = ["${aws_lb_target_group.my_tg.arn}"]

  ec2_scale_up_adjustment       = "1"
  cw_high_threshold             = "60"
  scaling_notification_topic    = "${module.sns_sqs.topic_arn}"
  cw_low_threshold              = "30"
  resource_name                 = "ECS-Cluster-ASG"
  ec2_scale_up_cool_down        = "60"
  ssm_patching_group            = "MyPatchGroup1"
  health_check_grace_period     = "300"
  security_group_list           = ["${module.vpc.default_sg}", "${aws_security_group.allow_web.id}"]
  perform_ssm_inventory_tag     = "True"
  terminated_instances          = "30"
  health_check_type             = "EC2"
  cw_low_evaluations            = "3"
  cw_high_evaluations           = "3"
  primary_ebs_volume_iops       = "0"
  detailed_monitoring           = "True"
  primary_ebs_volume_type       = "gp2"
  primary_ebs_volume_size       = "20"
  scaling_max                   = "2"
  cw_high_operator              = "GreaterThanThreshold"
  install_codedeploy_agent      = "False"
  asg_wait_for_capacity_timeout = "10m"
  initial_userdata_commands     = "${module.ecs_cluster.cluster_join_command}"
}

resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = "${lower(var.task_name)}"
  container_definitions    = "${data.template_file.ec2ecs-sample-app.rendered}"
  network_mode             = "${var.network_mode}"
  execution_role_arn       = "${aws_iam_role.ecs_role_task_assume.arn}"
  requires_compatibilities = ["EC2"]
}

resource "aws_ecs_service" "ecs_service_def" {
  name            = "${lower(var.service_name)}"
  cluster         = "${module.ecs_cluster.cluster_id}"
  task_definition = "${aws_ecs_task_definition.ecs_task_def.arn}"
  desired_count   = "${var.ecs_service_desired_count}"
}

## ECR Provisioning

resource "random_string" "ecr_rstring" {
  length  = 18
  upper   = false
  special = false
}

module "ecr_repo" {
  source              = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/ecr/?ref=v0.0.2"
  provision_ecr       = true
  ecr_repository_name = "myrepo-${random_string.ecr_rstring.result}"

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

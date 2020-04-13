/**
* # aws-terraform-ecs/modules/service_taskdef
* This submodule shows examples of service and task definitions
*
* # Service and Task Defintions
* Note: This is not a module and will not be being that service and task definitions are different for every application on ECS. This folder is however a guide on how to get started with ECS Service and Task Definitions.
*
* ## Odd Quirks
* Note that there is an odd behavior when a new task is created, the old version is deregistered and not available to be used again. You are _NOT_ able to revert to the old version. This is very dissimilar to lambdas. [link](https://github.com/terraform-providers/terraform-provider-aws/issues/258) As you change/update the current task definition in terraform, the default behavior is to create a new task definition version if you are using the same name. As soon as it is created the old one is *deregistered. If you need to roll back to a setup the same as the old definition, make sure you update to a new name to roll forward, as rolling backward is unsupported in terraform.
*
* ## Fargate Note on task definitions
* - Be sure to use FARGATE launch type
* - With Fargate you MUST use awsVPC
* - Fargate requires you specify the size of each task.
*
*
* ## Helpful links
* - [Task Definition Parameters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html)
* - [Fargate Task Definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-task-defs)
* - [Fargate Tasks and Services](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-tasks-services)
*
* Full working references are available at [examples](examples)
*/

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.7.0"
  }
}

# Specify the provider and access details
provider "aws" {
  region  = var.aws_region
  version = "~> 2.7"
}

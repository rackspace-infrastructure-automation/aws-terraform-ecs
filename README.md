> [!CAUTION]
> This project is end of life. This repo will be deleted on June 2nd 2025.

# aws-terraform-ecs

This repository contains terraform modules that can be used to Elastic Container Service cluster or Elastic Container Registry repo.

## Module listing
- [cluster](./modules/cluster) - A terraform module that can be used to create an IAM role and when appropriate, and IAM instance profile.  This module can create both cross account roles, and service roles.
- [ecr_repo](./modules/ecr) - A terraform module to provision Elastic Container Registry repo with a repo policy that controls access and lifecycle policy for images.
- [service_taskdef](./modules/tasks) - A terraform module to deploy the required task definitions for the ecs cluster.

## Examples
- [EC2 ECS Example](./examples/EC2/README.md)
- [FARGATE ECS Example](./examples/FARGATE/README.md)

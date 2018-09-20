# aws-terraform-ecr

This repository contains terraform modules that can be used to Elastic Container Service cluster or Elastic Container Registry repo. 

## Module listing
- [cluster](./modules/cluster) - A terraform module that can be used to create an IAM role and when appropriate, and IAM instance profile.  This module can create both cross account roles, and service roles.
- [ssm_service_roles](./modules/ecr) - A terraform module to provision Elastic Container Registry repo with a repo policy that controls access and lifecycle policy for images.

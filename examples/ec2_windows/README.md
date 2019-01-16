## Example of ECS EC2 Cluster

This is an example of an ECS cluster running with the Rackspace VPC and EC2 modules.

Its recommended to use a template file for your container definitions as its easier to update this for a customer.

Here, we the AMI is provided via a dynamic lookup to the latest Windows 2016 ECS AMI. Depending on the customers release strategy for new instances you may want to change this.

Copy the `terraform.tfvars.example` file in place and name it `terraform.tfvars` so it is automatically pulled into your `terraform` commands. Update it with your variable answers.

If you do not need to provide IAM keys (using config files, profiles, SSO, etc.) you can remove the use of `aws_secret_key` ad `aws_access_key` from `main.tf`, `variables.tf` and your copied `terraform.tfvars` files.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_access_key | AWS Access Key stored in secrets | string | - | yes |
| aws_region | AWS REGION | string | - | yes |
| aws_secret_key | AWS Secret Key stored in secrets | string | - | yes |
| ec2_keypair | SSH keypair for the EC2 Instances available in the build region | string | - | yes |
| ecs_cluster_name | The name to be given to the ECS cluster | string | - | yes |
| ecs_service_desired_count | Desired count for the ECS service | string | - | yes |
| environment | The environment we are building for | string | - | yes |
| service_name | The name of the service | string | - | yes |
| task_name | The name for the task | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| ecr_repository_name | Name of the ECR repository |
| ecr_repository_registry_id | Name of the ECR repository |
| ecr_repository_registry_url | URL of the ECR repository |

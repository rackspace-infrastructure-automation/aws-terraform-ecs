# aws-terraform-ecs/modules/cluster

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster_name | A name for the ECS cluster, up to 255 letters, numbers, hyphens, and underscores. | string | - | yes |
| environment | Application environment for which this cluster is being created. Preferred values are Development, Integration, PreProduction, Production, QA, Staging, or Test | string | `Development` | no |
| tags | Custom tags to apply to all resources. | string | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_arn | The ARN of the cluster |
| cluster_id | The ID of the cluster |
| cluster_join_command_linux | The command to join the cluster, to run on a Linux EC2 Instance. |
| cluster_join_command_windows | The command to join the cluster, to run on a Windows EC2 Instance. |

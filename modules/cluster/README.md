## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ecs_cluster_name | A name for the cluster | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_arn | The ARN of the cluster |
| cluster_id | The ID of the cluster |
| cluster_join_command | The join command to join the cluster, to run on the EC2 Host Instance. |

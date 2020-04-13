# aws-terraform-ecs/modules/cluster

This submodule creates an ecs cluster

## Basic Usage

```
module "ecs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/cluster/?ref=v0.12.0"

  name = "MyCluster"

  tags = {
    Terraform = "true"
  }
}
```

Full working references are available at [examples](examples)

## Terraform 0.12 upgrade

Several changes were required while adding terraform 0.12 compatibility.  The following changes should be  
made when upgrading from a previous release to version 0.12.0 or higher.

### Terraform State File

Several resources were updated with new logical names, better meet current Rackspace style guides.  
The following statements can be used to update existing resources.  In each command, `<MODULE_NAME>`  
should be replaced with the logic name used where the module is referenced.

```
terraform state mv module.<MODULE_NAME>.aws_ecs_cluster.ecs-cluster module.<MODULE_NAME>.aws_ecs_cluster.ecs_cluster
```

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.7.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | Application environment for which this cluster is being created. Preferred values are Development, Integration, PreProduction, Production, QA, Staging, or Test | `string` | `"Development"` | no |
| name | A name for the ECS cluster, up to 255 letters, numbers, hyphens, and underscores. | `string` | n/a | yes |
| tags | Custom tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_arn | The ARN of the cluster |
| cluster\_id | The ID of the cluster |
| cluster\_join\_command\_linux | The command to join the cluster, to run on a Linux EC2 Instance. |
| cluster\_join\_command\_windows | The command to join the cluster, to run on a Windows EC2 Instance. |


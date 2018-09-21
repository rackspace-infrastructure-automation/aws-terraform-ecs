## Example of ECS EC2 Cluster

This is an example of an ECS cluster running with the Rackspace VPC and EC2 modules.
Its recommended to use a template file for your container definitions as its easier to update this for a customer.
To note here, is the AMI is a dynamic lookup to the latest ECS AMI. Depending on the customers release strategy for new instance you may want to change this.

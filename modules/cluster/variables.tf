variable "cluster_name" {
  description = "A name for the ECS cluster, up to 255 letters, numbers, hyphens, and underscores."
  type        = "string"
}

variable "environment" {
  description = "Application environment for which this cluster is being created. Preferred values are Development, Integration, PreProduction, Production, QA, Staging, or Test"
  type        = "string"
  default     = "Development"
}

variable "tags" {
  description = "Custom tags to apply to all resources."
  default     = {}
}

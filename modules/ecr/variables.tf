## ECR related variables

variable "ecr_lifecycle_policy_text" {
  description = "The JSON repository policy text to apply to the repository. The length must be between 100 and 10,240 characters."
  type        = string
  default     = ""
}

variable "ecr_repository_policy_text" {
  description = "A JSON policy that controls who has access to the repository and which actions they can perform on it."
  type        = string
  default     = ""
}

variable "name" {
  description = "A name for the image repository"
  type        = string
  default     = ""
}

variable "provision_ecr" {
  description = "Provision ECR resource? true or false"
  type        = bool
  default     = false
}

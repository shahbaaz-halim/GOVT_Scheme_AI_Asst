

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-2"
}

variable "project_name" {
  description = "Base name for project resources"
  type        = string
  default     = "govt-scheme-ai-asst"
}
variable "region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "prefixo no projeto"
  type        = string
  default     = "iac"
}

variable "username" {
  description = "The username for the DB master user"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "The password for the DB master user"
  type        = string
  sensitive   = true
}

variable "bucket_names" {
  description = "s3 bucket names"
  type        = list(string)
  default = [
    "landing-jvam-iac",
    "bronze-jvam-iac",
    "silver-jvam-iac",
    "gold-jvam-iac",
    "scripts-jvam-iac"
  ]
}

locals {
  prefix = var.prefix
  common_tags = {
    Environment = "dev"
    Project     = "projeto-iac-aws"
  }
}
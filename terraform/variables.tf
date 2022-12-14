variable "region" {
  default = "eu-west-1"
  description = "AWS region"
}

variable "prefix" {
  default = "pakalucki"
  description = "Prefix used in naming convention of resources"
}

variable "base_cidr_block" {
  default = "10.0.0.0/16"
  description = "Base CIDR block for VPC"
}
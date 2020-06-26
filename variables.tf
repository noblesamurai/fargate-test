variable "profile" {
  description = "AWS API key credentials to use"
  type = string
  default = "default"
}

variable "region" {
  description = "AWS Region the infrastructure is hosted in"
  type = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  type = number
}

# Create a local value containing the number of bits required to represent each unique AZ.
locals {
  az_newbits = ceil(log(var.az_count * 2, 2))
}

variable "task_cpu" {
  type = number
  default = 1024
}

variable "task_memory" {
  type = number
  default = 3072
}

variable "env" {
  description = "Environment (dev/staging/prod)"
  type        = string
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "project" {
  type    = string
  default = "terraform_with_ansible"
}

variable "vpc_id" {
  type    = string
  default = "ID of my AWC VPC"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  type    = string
  description = "AMI to use for instances (Amazon Linux 2 recommended for built-in SSM agent)"
  default = "" # set in pipeline or override
}
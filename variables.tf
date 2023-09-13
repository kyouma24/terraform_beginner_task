variable "access_key" {
    default = "something"
}

variable "secret_access_key" {
    default = "something"
}

variable "s3_bucket" {
    default = "s3tfstatebackend382518"
}

variable "dynamodb_table" {
    default = "tf-state-locks"
}

variable "region" {
    default = "us-east-1"
}

variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}

variable "availability_zone" {
    default = "us-east-1a"
}

variable "aws_key_pair" {
    default = "tfkey"
}

variable "subnet_cidr_block" {
    default = "10.0.1.0/24"
}

variable "ami_id" {
    default = "ami-053b0d53c279acc90"
}

variable "ingress_ports" {
  type        = list(number)
  default     = [80, 443, 22]
}

variable "egress_ports" {
  description = "List of ports to open for egress"
  type        = list(number)
  default     = [80, 443, 22]
}
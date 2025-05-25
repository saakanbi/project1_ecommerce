variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 20.04"
  default     = "ami-0e58b56aa4d64231b"
}

variable "instance_type" {
  description = "Instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the existing EC2 Key Pair (not the .pem file)"
  default     = "sunday"
}

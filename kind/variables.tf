variable "region" {
    default = "us-east-1"
}

variable "cidr" {
    default = "10.0.0.0/16"
}

variable "availability_zone" {
    default = "us-east-1a"
}

variable "instance_type" {
    default = "t2.micro"
}

variable "ami" {
    default = "ami-0866a3c8686eaeeba"
}

variable "key" {
    default = "aws-keypair-1"
}

variable "vpc" {
    default = "myvpc"
}

variable "vpc_sub" {
    default = "myvpc_sub"
}
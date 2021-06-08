provider "aws" {
 region = "eu-west-1"
 profile = "lab"
 }




resource "aws_vpc" "chaituvpc" {
  #cidr_block       = "10.0.0.0/16"
  cidr_block       = "172.2.2.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "subnet1" {
  vpc_id     = aws_vpc.chaituvpc.id
  cidr_block = "172.2.0.0/16"
}

resource "aws_subnet" "in_secondary_cidr" {
  vpc_id     = aws_vpc_ipv4_cidr_block_association.secondary_cidr.vpc_id
  cidr_block = "172.2.0.0/24"
}

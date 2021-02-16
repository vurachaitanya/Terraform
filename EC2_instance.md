- Resources - Physical server, vm, containers, DB server, etc.
- Resource life cycle - `validateResources, diff, apply`
- Resource dependency after `apply` or `terraform graph` to show tree.

- EC2 instance 
- working dir `administrator-key-pair-uswest1.pem` has the token 
- terraform.tfvars has variables `aws_access_key`, `aws_secret_key`, `private_key_path` defined to make it secret.
- terraform apply -var-file='../terraform.tfvars'

```
cat config.tf
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {default = "administrator-key-pair-uswest1"}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "us-west-1"
 }
resources "aws_instance" "webserver" {
  ami = "ami-b2427ad2"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
 }
output "aws_instance_public_dns" {
  value = "${aws_instance.webserver.public_dns}"
 }
```

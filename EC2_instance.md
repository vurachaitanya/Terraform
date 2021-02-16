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

- handles dependency tree 
```
resource "aws_eip" "ip" {
  instance = "${aws_instance.webserver.id}"
}  
```
#### implecit dependency
- By default Terraform will take care of dependency for few resources
#### explicit dependency
- If we want to explicitly mention the dependency need to add `depends_on`

```
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
  depends_on = ["aws_s3_bucket.mys3bucket"]
 }
 
  resource "aws_eip" "ip" {
    instance = "${aws_instance.webserver.id}"
  } 
  
  resource "aws_s3_bucket" "mys3bucket" {
    bucket = "sd-terr-terraform101-bucket"
    acl = "private"
  }

output "aws_instance_public_dns" {
  value = "${aws_instance.webserver.public_dns}"
 }
```

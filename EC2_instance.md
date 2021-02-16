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

#### Provisioners 
- provisioners are used to execute scripts 
- can be used on local or remote machines
- used as part of resource creation or destruction
- bootstrapping the resource, its not to replace config management tool.
#### Creation-time Provisioners
- by default, provisioners run when a resource is created
- only run during creation
- Do not run during any update or any other life cycle
- creation time provisioners offers a ways to perform bootstrapping of a system
#### Destroy-time provisioners
- Destroy-time provisioners run before a resource is destroyed 
- specify `when = "destroy"` within the provisioner block .
#### local-exec 
- Provisioners invokes a local executable once a resource has been created. 

```
resource "aws_instance" "webserver" {
  ami = "ami-b243433"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  
  provisioner "local-exec" {
    command = "echo $"{aws_instance.webserver.public_ip} > my_ip_address.txt
  }
}

```
#### Creation-time Provisioners:
- when resource is created 

#### Destroy-time Provisioners:

- When the resource is destroyed

```
resource "aws_instance" "webserver" {
  ami = "ami-b243433"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  
  provisioner "local-exec" {
    command = "echo $"{aws_instance.webserver.public_ip} > my_ip_address.txt
  }
  provisioner "local-exec" {
    when = "destroy"
	command = "echo ${self.private_dns} destroyed >> my_ip_address.txt"
  }
}

```

#### Failed Provisioners
- Failed provisioners can leave resources in a semi-configuured state
- The `on_failure` attribute can change the behavior of the provisioner
- continue - Ignore the error and continue
- fail - error.

#### Tainted resources
- Resource is denoted tained when a resource is created but fails during provissioning.
- A tainted resource is considered unsafe
- A tained resource will be destroyed and recreated
- will recreate in next apply cycle when provisioner is failed is call Tainted recreate
- Can be seen in `terraform plan` command as tained

#### Modules
- Modules are self-contained packages of configuration managed as a group
- Modules allow you to 
  - create reusable componets
  - improve organization
  - treat pieces of infrastructure as a black box.
#### Steps followed in Modules
- the module block tells terraform to create and manage a module
- the only mandatory key of modules is the source configuration
- this provides the location of the module
- automatically downloads and manages the modules

#### Syntax of module
- Module name - Name of the module.
- Source - Source url or file path.
- configuration.

#### Terraform get 
- will get all the respective modules. 
- download from respective locations (HTTP, S3, Git, file location, etc)
- will not download again if once done.
- below command if already downloaded will not get the updates, so by setting update=true will get the updated module with new parameters if any recent changes were done.
`terraform get -update=true`

#### Output module
- Syntax Module_moduleName_resourceName
```
output "aws_instance_public_dns" {
  value = "{aws_instance.webserver.public_dns}"
 }
 
output "child_memory" {
  value = "${module.chail.received}"
 }
  
```
### Variable:
- defined in variable.tf file.
- Syntax :
`variable "aws_access_key" {}`
```
variable "key_name" {
  type = "string"
  default = "administrator-key-pair-uswest1"
}
```
- We can give variables in list and map

```
variable "zones" {
  type = "list"
  default = ["us-west-1a","us-west-1b"]
 }
```

```
variable "image" {
  type = "map"
  default = {
    us-west-1 = "ami-1c1d217c"
	us-west-2 = "ami-0a00ce72"
  }
}
```
- can called using `"${var.image.["us-west-1"]}"`

#### Modules :
-	Modules are reusable components 
-	Need to call in current tf files.
-	Current working dir is called root module
-	Strecture should be maintained. 
-	-root-child
-	Redme , License (Publish it externally), main.tf,outputs.tf,variables.tf
-	Even if files are empty, we can have placed empty files.
-	Description would be helpful.
```
module "chaild" {
  source = "./chaild"
  name = "example"
  description = "Just an example of modules"
  memory = "8GB"
}
```
- To call it main.tf files
```
output "chaild_memory" {
  value = "${module.child.received}"
}
```
- `terraform get` will get the required modules to local.
- `terraform refresh -var-file='../terraform..tfvars'`


- In main.cf
- It should be unique 
- can only valied in local module.
```
locals {
  default_prefix = "${var.project_name}-webserver"
}
```

- In output.tf file 

```
output "project_resource_type" {
  value = "${local.default_prefix}-EC2"
  description = "providing a means to demonstrate how to interpolate locals"
}
```
- `terraform get -update-true` after updating local we need to make sure to get it updated.
- `terraform refresh -var-file='../terraform.tfvars'` will update the local variables.

#### Resources:
- type of resource and name of resource, should be unique
- resource has doc which describes  more about resources
- provisioner is dependent on resource type and is not equal on all cloud providers. 
```
resource "aws_instance" "webserver" {
  ami = "ami-b2527ad2"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  
  provisioner "remote-exec" {
    inline = [
	"sudo apt-get update",
	"sudo apt-get install nginx -y",
	"sudo service nginx start"
	]
	
	connection {
	  user = "ubuntu"
	  private_key = "${file(var.private_key_path)}"
	}
  }
}
```

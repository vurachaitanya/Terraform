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

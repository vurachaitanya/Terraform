## Terraform Cheetsheet :

- List all resources, including modules: `terraform state list`
- `terraform init` helps Terraform read configuration files in the working directory. Then, Terraform finds out the necessary plugins and searches for installed plugins in different locations. In addition, Terraform also downloads additional plugins at times. Then, it decides the plugin versions for using and writes a lock file for ensuring that Terraform will use the same plugin versions. 
- `terraform output -raw` - shows output only in raw format.
- `terraform graph | dot -Tsvg >graph.svg` Shows graph dig with dependency 
- `terraform init` initialize a working direct
-	`terraform plan` checks the dependency and download provider, modules and check the modules and download to current working dir
-	`terraform providers` shows information about provider requirements of the configuration in the current working dir.
-	`terraform fmt` rewrite Terraform configuration files to a canonical format and style. This command applies a subset of the Terraform language style conventions, along with other minor adjustments for readability.
-	`terraform apply` implement the current working dir configurations and creates states files
-	`terraform apply -auto-approve` Terraform skip interactive approval
-	`terraform destroy` destroys the current working dir configurations based on configurations & State file. 
-	 `terraform console` interactive command-line console for evaluating and experimenting.
-	`terraform validate` validates the configuration files in a directory, referring and not accessing any remote services. configuration is syntactically valid and internally consistent, regardless of any provided variables or existing state.
-	`terraform show` human readable output from a state or plan file.
-	`terraform state list ` list all resources in the state file.
-	`terraform state show` shows the attributes of a single resource
-	`terraform taint` manually marks a terraform managed resource as tainted, forcing it to be destroyed and recreated on the next apply.
- `terraform graph -verbose -draw-cycles -type=plan` - Graph based on plan
`-type=plan - Type of graph to output. Can be: plan, plan-destroy, apply, validate, input, refresh`
- `terraform graph -draw-cycles` - Draw cycles for modules providers etc.
- `terraform graph | dot -Tsvg > graph.svg` - Graph from dot to svg format.
- `terraform show` - Shows the state of the terrform resources.
- `terraform state list` - Shows the list of modules used.

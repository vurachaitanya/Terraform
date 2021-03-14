## Terraform Cheetsheet :



- List all resources, including modules: `terraform state list`
- `terraform init` helps Terraform read configuration files in the working directory. Then, Terraform finds out the necessary plugins and searches for installed plugins in different locations. In addition, Terraform also downloads additional plugins at times. Then, it decides the plugin versions for using and writes a lock file for ensuring that Terraform will use the same plugin versions. 
- `terraform output -raw` - shows output only in raw format.
- `terraform graph | dot -Tsvg >graph.svg` Shows graph dig with dependency 
- 

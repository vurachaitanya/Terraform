
### Terraform 
-	Version 0.12 will not working with terraform{} – Block
-	Version 0.11 before version requires `terraform init` & `terraform plan`
-	Below sample .tf file contains:
  - **Terraform block:** – only before version of terraform 0.12
  - **Required providers block:** – to know which providers are we using to get required API plugins.
  - **Provider block:** AWS provider specific like auth keys, region, IAM access, region etc.
  - **Resources block:** what type of resources we are using in, name of the resources, instance type, network type etc. if not mentioned try to use default values provided by provider plugins 

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
}
```  
- After Terraform apply : 
- When the value displayed is (known after apply), it means that the value won't be known until the resource is created.
- When you applied your configuration, Terraform wrote data into a file called terraform.tfstate. This file now contains the IDs and properties of the resources Terraform created so that it can manage or destroy those resources going forward.
- Provider that is built in to Terraform itself `terraform_remote_state  terraform.io/builtin/terraform`

- **Terraform Core** reads the configuration and builds the resource dependency graph.
- **Terraform Plugins** (providers and provisioners) bridge Terraform Core and their respective target APIs. Terraform provider plugins implement resources via basic CRUD (create, read, update, and delete) APIs to communicate with third party services.
- Terraform Core reads the configuration and builds the resource dependency graph.
- Terraform Plugins (providers and provisioners) bridge Terraform Core and their respective target APIs. Terraform provider plugins implement resources via basic CRUD (create, read, update, and delete) APIs to communicate with third party services.

#### Variable can be specified in 3 ways 
1.	export TF_VAR_region=”us-east-1” && Terraform apply 
2.	From Variables.tf file
```cat  variables.tf
variable “region” {
	 default = "us-east-1"
}
```
- in main.tf file 
```
provider "aws" {
  profile = "default"
  region  = var.region 
} 
```
3. Command line if above var file is not created `terraform apply -var="region=us-east-1"` this will not save conf in any files.
4. create a file name terraform.tfvar or auto.tfvar 

```cat terraform.tfvar
region = "us-east-1"
```
5. `terraform apply -var-file="abc.tfvar"` we can keep adding more --var-file tags with many files.

#### List
- Declare implicitly by using brackets []
`variable "cidrs" { default = [] }`

- Declare explicitly with 'list'
`variable "cidrs" { type = list }`

#### Maps / Dict :
```
variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-b374d5a5"
    "us-west-2" = "ami-fc0b939c"
  }
}

```

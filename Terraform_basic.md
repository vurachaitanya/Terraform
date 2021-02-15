
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

#### [Maps / Dict :](https://learn.hashicorp.com/tutorials/terraform/aws-variables?in=terraform/aws-get-started#assigning-maps)
```
variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-b374d5a5"
    "us-west-2" = "ami-fc0b939c"
  }
}

```
```
resource "aws_instance" "example" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
}
```

####  [Variable blocks have three optional arguments.](https://learn.hashicorp.com/tutorials/terraform/variables?in=terraform/configuration-language)

- Description: A short description to document the purpose of the variable.
- Type: The type of data contained in the variable.
- Default: The default value.

```
########### String
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

################ Number
variable "instance_count" {
  description = "Number of instances to provision."
  type        = number
  default     = 2
}

################ Boolian
variable "enable_vpn_gateway" {
  description = "Enable a VPN gateway in your VPC."
  type        = bool
  default     = false
}

################## List 
variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
  default     = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
  ]
}


#################### Dic / Map
variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    project     = "project-alpha",
    environment = "dev"
  }
}

```


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

- Type for the list variables is list(string). Each element in these lists must be a string. List elements must all be the same type, but can be any type, including complex types like list(list) and list(map).
- you can refer to individual items in a list by index, starting with 0.
```
> var.private_subnet_cidr_blocks[1]
"10.0.102.0/24"
```
- Use the slice() function to get a subset of these lists.
```
> slice(var.private_subnet_cidr_blocks, 0, 3)
tolist([
  "10.0.101.0/24",
  "10.0.102.0/24",
  "10.0.103.0/24",
])
```

#### terraform console
- The Terraform console command opens an interactive console that you can use to evaluate expressions in the context of your configuration. This can be very useful when working with and troubleshooting variable definitions.
- Call varilables which are defined in variables.tf or any variables file can be called and debug using `var.aws_region`

#### MAPS:
- Setting the type to map(string) tells Terraform to expect strings for the values in the map. Map keys are always strings. Like dictionaries or maps from programming languages, you can retrieve values from a map with the corresponding key
```
variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    project     = "project-alpha",
    environment = "dev"
  }
}
```
- Can retrive the data using Key value `var.resource_tags["environment"]`

#### Assign values when prompted
- Terraform will prompt you for a value. Entering variable values manually is time consuming and error prone, so Terraform provides several other ways to assign values to variables.
- Terraform automatically loads all files in the current directory with the exact name terraform.tfvars or matching *.auto.tfvars. You can also use the -var-file flag to specify other files by name.
- Create a file terraform.tfvars
```
resource_tags = {
  project     = "new-project",
  environment = "test",
  owner       = "me@example.com"
}

ec2_instance_type = "t2.nano"

instance_count = 3
```
#### Interpolate variables in strings
- Terraform configuration supports string interpolation — inserting the output of an expression into a string. This allows you to use variables, local values, and the output of functions to create strings in your configuration.

```
Access_key = “${var.aws_access_key}”
Secret_key = “${var.aws_secret_key}”

name        = "web-sg-project-alpha-dev"
name        = "web-sg-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"

```
#### Validate variables
- This configuration has a potential problem. AWS load balancers have naming restrictions. They must be no more than 32 characters long, and can only contain a limited set of characters.
```
variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    project     = "my-project",
    environment = "dev"
  }

  validation {
    condition     = length(var.resource_tags["project"]) <= 16 && length(regexall("/[^a-zA-Z0-9-]/", var.resource_tags["project"])) == 0
    error_message = "The project tag must be no more than 16 characters, and only contain letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.resource_tags["environment"]) <= 8 && length(regexall("/[^a-zA-Z0-9-]/", var.resource_tags["environment"])) == 0
    error_message = "The environment tag must be no more than 8 characters, and only contain letters, numbers, and hyphens."
  }
}
```

#### IF Condetion	
- If above env is production then var.prod_subnet will be taking the subnet values else it takes var.dev_subnet values. 
`subnet = “${var.env == “production” ? var.prod_subnet : var.dev_subnet}”`


- [Built in function](www.terraform.io/docs/configuration/interpolation.html)
- **HCL** : Hashicorp configuration language
- When file **xxx_override.tf** is created it over rights the other files and take preceding of override files.
- **Output** 
 ```
 Output "output” {
	  value = “${aws_instacne.webserver.public_dns}”
	}
- Sensitive output will not show on screen
- Terraform output will show the sensitive data too.
```
output “output” {
	  Sensitive = true
	  Value = “${aws_instacne.webserver.public_dns}”
	}
- Provider should be initialized first and then resource should be used in second. 
- Many provider can be kept and alias can also ben given.
- Provider can have config items and key values.
- 3rd party providers plugins can be added under ~/.terraform.d/plugins

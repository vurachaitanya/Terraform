
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
```  *  **

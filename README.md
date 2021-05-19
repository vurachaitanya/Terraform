# Terraform

### Terraform Learning
- Resource example :"aws_internet_gateway"
- Provider example : "aws" in providers files.
- [Git repo for sample terraform aws application build.](https://github.com/linuxacademy/content-deploying-to-aws-ansible-terraform/tree/master/iam_policies)
- [Sample doc](https://medium.com/appgambit/terraform-aws-vpc-with-private-public-subnets-with-nat-4094ad2ab331)

### Tools :
- [Terraform Graph - Blast radius](https://28mm.github.io/blast-radius-docs/)
- [Terraform Chekov GUI tool](https://github.com/bridgecrewio/checkov/blob/master/docs/Chekov_sequence_diagram.png), [Scanning-terraform-module](https://github.com/bridgecrewio/checkov/blob/master/docs/scanning-terraform-module.png), [Scanns for failed modules](https://github.com/bridgecrewio/checkov/blob/master/docs/checkov-scan.png)
- [Output from terraform plan get details](https://prettyplan.chrislewisdev.com/),[Git code works for x.11 only](https://github.com/chrislewisdev/prettyplan)

### Learnings
- [Docker Blast radius deploy](https://github.com/28mm/blast-radius)
- [Linuxfoundation Terraform deep dive](https://events19.linuxfoundation.org/wp-content/uploads/2017/12/Hashicorp-Terraform-Deep-Dive-with-no-Fear-Victor-Turbinsky-Texuna.pdf)
- [awesome-terraform](https://github.com/shuaibiyy/awesome-terraform)
- [CI/CD tools stack](https://blog.gruntwork.io/)
- [Terraform Production Pipeline with Multi-branch Pipeline](https://youtu.be/SikT2uinPXo)
- [Terraform 101 by Hashi Corp](https://www.hashicorp.com/events/webinars/terraform-cloud-and-terraform-enterprise-101?mkt_tok=ODQ1LVpMRi0xOTEAAAF8_KHwHoWUW4ZpT9zbWd8Iod3zd1fMx7j1w9OGR26Vq1uDD3LFyeOBWPcsjySzYeoLzZiGyLnU18dRqOL2vC93RabIUamsQEN5qmF6j1mlZRPQ3A)


#### Sample Variable file :
```
#cat variable.tf
variable "profile" {
  type    = string
  default = "default"
}

variable "region-master" {
  type    = string
  default = "us-east-1"
}
variable "region-worker" {
  type    = string
  default = "us-west-2"
}

```

#### Sample Providers file :
```
#cat providers.tf
provider "aws" {
  profile                 = var.profile
  region                  = var.region-master
  shared_credentials_file = "/root/aws/tf/.aws/credentials"
  alias                   = "region-master"
}

provider "aws" {
  profile                 = var.profile
  region                  = var.region-worker
  shared_credentials_file = "/root/aws/tf/.aws/credentials"
  alias                   = "region-worker"
}
```

#### sample Network file which is using variables & providers file :
```
#cat networks.tf
#Create VPC in us-east-1
resource "aws_vpc" "vpc_master" {
  provider             = aws.region-master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "master-vpc-jenkins"
  }

}

#Create VPC in us-west-2
resource "aws_vpc" "vpc_master_oregon" {
  provider             = aws.region-worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "worker-vpc-jenkins"
  }

}

#Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
}

#Create subnet # 1 in us-east-1
resource "aws_subnet" "subnet_1" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"
}
```

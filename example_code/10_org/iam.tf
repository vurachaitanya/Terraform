#provider "aws" { }
#region = "us-gov-west-1"
#provider.aws.region
####### Create New ORG
#resource "aws_organizations_organization" "chaituorg" {
#  aws_service_access_principals = [
#    "cloudtrail.amazonaws.com",
#    "config.amazonaws.com",
#  ]
#
#  feature_set = "ALL"
#}


resource "aws_organizations_organizational_unit" "chaituOU" {
  name      = "chaituOU"
  #parent_id = aws_organizations_organization.chaituOU.roots[0].id
  parent_id = "r-1hfz"
}

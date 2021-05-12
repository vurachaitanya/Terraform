//Policy created to Deny AWS Marketplace for Org users using SCP.

resource "aws_organizations_policy" "AWSMarket_deny_policy" {
  name = "AWSMarket_deny_policy"
  content = <<CONTENT
{
  "Version": "2012-10-17",
  "Statement": {
    "Sid": "MarketplaceDenyAccess",
    "Effect": "Deny",
    "Action": "aws-marketplace:*",
        "Resource": ["arn:aws:iam::aws:policy/AWSMarketplace*","arn:aws:iam::aws:policy/AWSPrivateMarketplace*"]
    }
}
CONTENT
}

// AWS Parent ID of the Org
resource "aws_organizations_organizational_unit" "marketspace_org_deny" {
  name      = "Marketspace Org Deny"
  parent_id = var.parent_id
}

resource "aws_organizations_policy_attachment" "marketspace_deny_policy_org" {
  policy_id = aws_organizations_policy.AWSMarket_deny_policy.id
  target_id = aws_organizations_organizational_unit.marketspace_org_deny.id
}

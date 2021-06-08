provider "aws" {
 region = "eu-west-1"
 profile = "personal"
 }

resource "aws_iam_role" "Launchpad_Developer_ACCESS" {
  managed_policy_arns = ["arn:aws-us-gov:iam::aws:policy/AWSCodeBuildDeveloperAccess",
 "arn:aws-us-gov:iam::aws:policy/AWSCodeCommitPowerUser",
 "arn:aws-us-gov:iam::aws:policy/AWSCodeDeployFullAccess",
 "arn:aws-us-gov:iam::aws:policy/AWSCodePipeline_FullAccess"]
  name               = "launchpad_developer"
  description        = "Role will have CodeCommitPowerUser,BuildDeveloper,CodeDeploy_F,CodePipeline_F"
  assume_role_policy = data.aws_iam_policy_document.trust_policy_federated_from_identity_master.json
}

data "aws_iam_policy_document" "trust_policy_federated_from_identity_master" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = [539462455535]
    }
  }
}

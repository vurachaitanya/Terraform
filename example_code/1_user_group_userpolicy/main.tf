provider "aws" {
 region = "us-east-1"
 #profile = "lab"
 profile = "personal"
 }

resource "aws_iam_user" "sampleuser1" {
  name = "sampleuser1"

  tags = {
    name = "chaitu"
  }
}



resource "aws_iam_group_membership" "samplegroup" {
  name = "samplegroup"

  users = [
    aws_iam_user.sampleuser1.name
  ]

  group = aws_iam_group.group.name
}

resource "aws_iam_group" "group" {
  name = "samplegroup"
}


resource "aws_iam_access_key" "lb" {
  user = aws_iam_user.sampleuser1.name
}

resource "aws_iam_user_policy" "chaitu-policy" {
  name = "chaitu-policy-ec2-describe"
  user = aws_iam_user.sampleuser1.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

provider "aws" {
 region = "us-east-2"
 profile = "lab"
 }


resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket-chaitu"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

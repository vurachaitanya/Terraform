provider "aws" {
 region = "eu-west-1"
 profile = "personal"
 }

 resource "aws_s3_bucket" "first_bucket" {
 bucket = "kevholditch-bucket-outputs-vura"
 }

 output "bucket_name" {
 value = aws_s3_bucket.first_bucket.id
 }

 output "bucket_arn" {
 value = aws_s3_bucket.first_bucket.arn
 }

 output "bucket_information" {
 value = "bucket name: ${aws_s3_bucket.first_bucket.id}, bucket arn: ${aws_s3_bucket.first_bucket.arn}"
 }

 output "all" {
 value = aws_s3_bucket.first_bucket
 }

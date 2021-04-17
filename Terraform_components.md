## Terraform Components

### Data Sources :
- [Terraform Doc Reff](https://www.terraform.io/docs/language/data-sources/index.html)
- [Terraform tutorial Reff](https://learn.hashicorp.com/tutorials/terraform/data-sources?in=terraform/configuration-language&utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS)
- Data sources allow data to be fetched or computed for use elsewhere in Terraform configuration. Use of data sources allows a Terraform configuration to make use of information defined outside of Terraform, or defined by another separate Terraform configuration.
- The name is used to refer to this resource from elsewhere in the same Terraform module, but has no significance outside of the scope of a module.
- The data source and name together serve as an identifier for a given resource and so must be unique within a module.


### aws_cloudwatch_event_rule :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)
- EventBridge was formerly known as CloudWatch Events. The functionality is identical.

```
resource "aws_cloudwatch_event_rule" "console" {
  name        = "capture-aws-sign-in"
  description = "Capture each AWS Console Sign In"

  event_pattern = <<EOF
{
  "detail-type": [
    "AWS Console Sign In via CloudTrail"
  ]
}
EOF
}
```

#### aws_cloudwatch_event_target :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)
- Event Trigger with ARN will help to triger the event block to cloudwatch.

```
resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.console.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.aws_logins.arn
}
```

### aws_lambda_permission :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)
- Gives an external source (like a CloudWatch Event Rule, SNS, or S3) permission to access the Lambda function.

```
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:eu-west-1:111122223333:rule/RunDaily"
  qualifier     = aws_lambda_alias.test_alias.name
}
```

### aws_cloudwatch_log_group :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)
- Provides a CloudWatch Log Group resource.
```
resource "aws_cloudwatch_log_group" "yada" {
  name = "Yada"
  retention_in_days = 14  

  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}

```

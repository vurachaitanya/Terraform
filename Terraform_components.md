## Terraform Components


### Terraform Environment variables :
- [TF Env Variables](https://www.terraform.io/docs/cli/config/environment-variables.html)


### tags :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging)
- Many AWS services implement resource tags as an essential part of managing components. These arbitrary key-value pairs can be utilized for billing, ownership, automation, access control, and many other use cases. Given that these tags are an important aspect of successfully managing an AWS environment, the Terraform AWS Provider implements additional functionality beyond the typical one-to-one resource lifecycle management for easier and more customized implementations.
```
resource "aws_vpc" "example" {
  # ... other configuration ...

  tags = {
    Name  = "MyVPC"
    Owner = "Operations"
  }

  lifecycle {
    ignore_changes = [tags.Name]
  }
}
```



### Variable :
- [Terraform Doc Reff](https://www.terraform.io/docs/language/values/variables.html#declaring-an-input-variable)
- Input variables serve as parameters for a Terraform module, allowing aspects of the module to be customized without altering the module's own source code, and allowing modules to be shared between different configurations.
- When you declare variables in the root module of your configuration, you can set their values using CLI options and environment variables
```
variable "user_information" {
  description = "this is user information"
  type = object({
    name    = string
    address = string
  })
  sensitive = true
}

resource "some_resource" "a" {
  name    = var.user_information.name
  address = var.user_information.address
}
```



### Locals :
- [Terraform Doc Reff](https://www.terraform.io/docs/language/values/locals.html)
- A local value assigns a name to an expression, so you can use it multiple times within a module without repeating it.
- If you're familiar with traditional programming languages, it can be useful to compare Terraform modules to function definitions:
  - Input variables are like function arguments.
  - Output values are like function return values.
  - Local values are like a function's temporary local variables.

 ```
 locals {
  service_name = "forum"
  owner        = "Community Team"
}
 ```
 - **Note**: Local values are created by a locals block (plural), but you reference them as attributes on an object named local (singular). Make sure to leave off the "s" when referencing a local value!
 ```
 locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}

resource "aws_instance" "example" {
  # ...

  tags = local.common_tags
}
```



### depends_on :
- [Terraform Doc Reff](https://www.terraform.io/docs/language/meta-arguments/depends_on.html)
- Explicitly specifying a dependency is only necessary when a resource or module relies on some other resource's behavior but doesn't access any of that resource's data in its arguments.
- This argument is available in module blocks and in all resource blocks, regardless of resource type.

```
resource "aws_iam_role_policy" "example" {
  name   = "example"
  role   = aws_iam_role.example.name
  policy = jsonencode({
    "Statement" = [{
      # This policy allows software running on the EC2 instance to
      # access the S3 API.
      "Action" = "s3:*",
      "Effect" = "Allow",
    }],
  })
}

resource "aws_instance" "example" {
  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"

  # Terraform can infer from this that the instance profile must
  # be created before the EC2 instance.
  iam_instance_profile = aws_iam_instance_profile.example

  # However, if software running in this EC2 instance needs access
  # to the S3 API in order to boot properly, there is also a "hidden"
  # dependency on the aws_iam_role_policy that Terraform cannot
  # automatically infer, so it must be declared explicitly:
  depends_on = [
    aws_iam_role_policy.example,
  ]
}
```



### output :
- [Terraform Doc Reff](https://www.terraform.io/docs/language/values/outputs.html)
- Output values are like the return values of a Terraform module, and have several uses:
  - A child module can use outputs to expose a subset of its resource attributes to a parent module.
  - A root module can use outputs to print certain values in the CLI output after running terraform apply.
  - When using remote state, root module outputs can be accessed by other configurations via a terraform_remote_state data source.
- Resource instances managed by Terraform each export attributes whose values can be used elsewhere in configuration. Output values are a way to expose some of that information to the user of your module.
- Terraform analyzes the value expression for an output value and automatically determines a set of dependencies, but in less-common cases there are dependencies that cannot be recognized implicitly. In these rare cases, the depends_on argument can be used to create additional explicit dependencies:
```
output "instance_ip_addr" {
  value       = aws_instance.server.private_ip
  description = "The private IP address of the main server instance."

  depends_on = [
    # Security group rule must be created before this IP address could
    # actually be used, otherwise the services will be unreachable.
    aws_security_group_rule.local_access,
  ]
}
```
- Terraform will hide values marked as sensitive in the messages from terraform plan and terraform apply. In the following scenario, our root module has an output declared as sensitive and a module call with a sensitive output, which we then use in a resource attribute.
```
output "db_password" {
  value       = aws_db_instance.db.password
  description = "The password for logging in to the database."
  sensitive   = true
}
```



### lifecycle:
- [Terraform Doc Reff](https://www.terraform.io/docs/language/meta-arguments/lifecycle.html)
- Lifecycle customizations to change default resource behaviours during apply
- lifecycle is a nested block that can appear within a resource block. The lifecycle block and its contents are meta-arguments, available for all resource blocks regardless of type.
  - create_before_destroy - bool
  - prevent_destroy - bool
  - ignore_changes - list of attribute names
```
resource "aws_instance" "example" {
  # ...

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

```




### Data Sources :
- [Terraform Doc Reff](https://www.terraform.io/docs/language/data-sources/index.html)
- [Terraform tutorial Reff](https://learn.hashicorp.com/tutorials/terraform/data-sources?in=terraform/configuration-language&utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS)
- Data sources allow data to be fetched or computed for use elsewhere in Terraform configuration. Use of data sources allows a Terraform configuration to make use of information defined outside of Terraform, or defined by another separate Terraform configuration.
- The name is used to refer to this resource from elsewhere in the same Terraform module, but has no significance outside of the scope of a module.
- The data source and name together serve as an identifier for a given resource and so must be unique within a module.




### aws_lambda_function_event_invoke_config :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config)
- Manages an asynchronous invocation configuration for a Lambda Function or Alias. 
```
resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_alias.example.function_name

  destination_config {
    on_failure {
      destination = aws_sqs_queue.example.arn
    }

    on_success {
      destination = aws_sns_topic.example.arn
    }
  }
}
```
- Error Handling Configuration
```
resource "aws_lambda_function_event_invoke_config" "example" {
  function_name                = aws_lambda_alias.example.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0
}
```



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



### aws_caller_identity
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)
- Use this data source to get the access to the effective Account ID, User ID, and ARN in which Terraform is authorized.

```
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
```



### aws_iam_policy_document :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)
- Generates an IAM policy document in JSON format for use with resources that expect policy documents such as `aws_iam_policy`
- Using this data source to generate policy documents is optional. It is also valid to use literal JSON strings in your configuration or to use the file interpolation function to read a raw JSON policy document from a file.
```
data "aws_iam_policy_document" "example" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
```



### aws_iam_policy:
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)
- Provides an IAM policy.
```
resource "aws_iam_policy" "example" {
  name   = "example_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.example.json
}
```



### aws_partition: 
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition)
- Use this data source to lookup information about the current AWS partition in which Terraform is working.
```
data "aws_partition" "current" {}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid = "1"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::my-bucket",
    ]
  }
}
```



### aws_region:
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)
- As well as validating a given region name this resource can be used to discover the name of the region configured within the provider. The latter can be useful in a child module which is inheriting an AWS provider configuration from its parent module.
- The following example shows how the resource might be used to obtain the name of the AWS region configured on the provider.
  - `data "aws_region" "current" {}`




### aws_iam_role :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
- Provides an IAM role.

```
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "instance_role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}
```



### aws_iam_role_policy_attachment :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)
- Attaches a Managed IAM Policy to an IAM role

```
resource "aws_iam_role" "role" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}
```



### aws_lambda_function :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)
- Provides a Lambda Function resource. Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
```
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "exports.test"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # 
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  ## runtime defines the env like python, nodejs, go1.x for runtime compiler
  runtime = "nodejs12.x"
  

  environment {
    variables = {
      foo = "bar"
    }
  }
}
```



### archive_file :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file)
- Generates an archive from content, a file, or directory of files.

- Archive a single file.
```
data "archive_file" "init" {
  type        = "zip"
  source_file = "${path.module}/init.tpl"
  output_path = "${path.module}/files/init.zip"
}
```

- Archive multiple files and exclude file.

```
data "archive_file" "dotfiles" {
  type        = "zip"
  output_path = "${path.module}/files/dotfiles.zip"
  excludes    = [ "${path.module}/unwanted.zip" ]

  source {
    content  = "${data.template_file.vimrc.rendered}"
    filename = ".vimrc"
  }

  source {
    content  = "${data.template_file.ssh_config.rendered}"
    filename = ".ssh/config"
  }
}
```


### aws_sns_topic :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)
- Provides an SNS topic resource

```
resource "aws_sns_topic" "user_updates" {
  name            = "user-updates-topic"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}
```
- Server-side encryption (SSE)
```
resource "aws_sns_topic" "user_updates" {
  name              = "user-updates-topic"
  kms_master_key_id = "alias/aws/sns"
}
```



### aws_sns_topic_subscription :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription)
- Provides a resource for subscribing to SNS topics. Requires that an SNS topic exist for the subscription to attach to. This resource allows you to automatically place messages sent to SNS topics in SQS queues, send them as HTTP(S) POST requests to a given endpoint, send SMS messages, or notify devices / applications. The most likely use case for Terraform users will probably be SQS queues.
```
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = "arn:aws:sns:us-west-2:432981146916:user-updates-topic"
  protocol  = "sqs"
  endpoint  = "arn:aws:sqs:us-west-2:432981146916:terraform-queue-too"
}
```



### aws_kms_key :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)
- Provides a KMS customer master key.
- policy - (Optional) A valid policy JSON document

```
resource "aws_kms_key" "a" {
  description             = "KMS key 1"
  deletion_window_in_days = 10
}
```



### aws_kms_alias :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)
- Provides an alias for a KMS customer master key. AWS Console enforces 1-to-1 mapping between aliases & keys, but API (hence Terraform too) allows you to create as many aliases as the account limits allow you.
- name_prefix - (Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word "alias" followed by a forward slash (alias/). Conflicts with
```
resource "aws_kms_key" "a" {}

resource "aws_kms_alias" "a" {
  name          = "alias/my-key-alias"
  name_prefix          = "my-key-us-west-1-"
  target_key_id = aws_kms_key.a.key_id
}
```



### aws_sns_topic_policy :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy)
- Provides an SNS topic policy resource
```
resource "aws_sns_topic" "test" {
  name = "my-topic-with-policy"
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.test.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account-id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.test.arn,
    ]

    sid = "__default_statement_ID"
  }
}
```




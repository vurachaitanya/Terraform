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


### Interpolation syntax :
- Sample code to create vpc & Security group creation using iterpolation.
- The neat thing about using interpolation syntax to reference the attribute of a resource in another resource is that it allows Terraform to work out the dependency order of the resources. From our HCL above Terraform can determine that first it needs to create the VPC because it needs the id that AWS assigns to the VPC in order to create the security group. It then knows that it needs to create the security group next as it needs the id of the security group in order to create the security group rule. Terraform uses this information to build up a dependency graph and then tries to run in parallel as much as possible.
```
provider "aws" {
 region = "us-east-1"
 profile = "personal"
 }

 resource "aws_vpc" "my_vpc" {
 cidr_block = "10.0.0.0/16"
 }

 resource "aws_security_group" "my_security_group" {
 vpc_id = aws_vpc.my_vpc.id                ############################# Interpolation syntax
 name = "Example security group"
 }

 resource "aws_security_group_rule" "tls_in" {
 protocol = "tcp"

 security_group_id = aws_security_group.my_security_group.id    ############################# Interpolation syntax
 from_port = 443
 to_port = 443
 type = "ingress"
 cidr_blocks = ["0.0.0.0/0"]
 }

```
- The format of using an output attribute from a resource is `<resource_type>.<resource_identifier>.<attribute_-name>`. In the VPC id example we are getting the output from an aws_vpc resource type, with the identifier name my_vpc and we want to get the id attribute value. So hence we end up with aws_vpc.my_vpc.id.


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





### AWS Organizations :
- [securing-access-to-amis-aws-marketplace](https://aws.amazon.com/blogs/awsmarketplace/securing-access-to-amis-aws-marketplace/)

- `aws_organizations_organizational_unit` - Provides a resource to create an organizational unit. [Terraform doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit)
```
resource "aws_organizations_organizational_unit" "example" {
  name      = "example"
  parent_id = aws_organizations_organization.example.roots[0].id
}
```

- `aws_organizations_policy` - Provides a resource to manage an AWS Organizations policy. [Terraform doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy)
```
resource "aws_organizations_policy" "example" {
  name = "example"

  content = <<CONTENT
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "*",
    "Resource": "*"
  }
}
CONTENT
}
```


- `aws_organizations_policy_attachment` - Provides a resource to attach an AWS Organizations policy to an organization account, root, or unit. [Terraform doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment)

```
resource "aws_organizations_policy_attachment" "root" {
  policy_id = aws_organizations_policy.example.id
  target_id = aws_organizations_organization.example.roots[0].id
}
```

- Create AWS SCP at Org leavel [AWS Doc](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html)
- [Old version of usage](https://github.com/trussworks/terraform-aws-org-scp)
- [Latest version of usage](https://github.com/trussworks/terraform-aws-ou-scp)

#####  Below block is to block S3 for blocking un encrypted data on S3 bucket 
- [Reff of below code](https://blog.scalesec.com/using-terraform-to-secure-your-aws-organizations-399c3dcb4b5a)
```
data "aws_iam_policy_document" "deny_unencrypted_uploads" {  
  statement {  
    sid = "DenyUnencryptedUploads" 

    actions = [  
         "s3:PutObject",
    ]     
 
    resources = [  
         "arn:aws:s3:::*/*",
    ]  
    
    effect = "Deny" 

    condition {  
      test     = "Null" 
      variable = "s3:x-amz-server-side-encryption" 

      values = [  
            "true",
      ]
    }
  }
}
resource "aws_organizations_policy" "deny_unencrypted_uploads" {  
  name        = "Deny Unencrypted S3 Uploads" 
  description = "Deny the ability to upload an unencrypted S3 Object." 

  content = 
"${data.aws_iam_policy_document.deny_unencrypted_uploads.json}"
}
resource "aws_organizations_policy_attachment" "deny_unencrypted_uploads_attachment" {  
  policy_id = "${aws_organizations_policy.deny_unencrypted_uploads.id}" 
  target_id = "${var.target_id}"
}
```




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
resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
```
- User existing data modules to create a policy
```
resource "aws_iam_policy" "example" {
  name   = "example_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.example.json
}
```


### aws_iam_policy_attachment :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment)
- Attaches a Managed IAM Policy to user(s), role(s), and/or group(s)
- **NOTE :** - users/roles/groups that have the attached policy via any other mechanism (including other Terraform resources) will have that attached policy revoked by this resource. Consider aws_iam_role_policy_attachment, aws_iam_user_policy_attachment, or aws_iam_group_policy_attachment instead. These resources do not enforce exclusive attachment of an IAM policy.
```
resource "aws_iam_user" "user" {
  name = "test-user"
}

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

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  users      = [aws_iam_user.user.name]
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy.arn
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
- Other ways of attacing policys to roles.
```
########### 1st way
resource "aws_iam_role_policy_attachment" "Dev_role_full" {
  role       = "${var.iam_role_name}"
  count      = "${length(var.iam_policy_arn)}"
  policy_arn = "${var.iam_policy_arn[count.index]}"
}

iam_policy_arn = ["arn:aws-us-gov:iam::aws:policy/AWSCodeBuildDeveloperAccess", 
 "arn:aws-us-gov:iam::aws:policy/AWSCodeCommitPowerUser",
 "arn:aws-us-gov:iam::aws:policy/AWSCodeDeployFullAccess",
 "arn:aws-us-gov:iam::aws:policy/AWSCodePipeline_FullAccess"]
 
 
########### 2nd way
 resource "aws_iam_role_policy_attachment" "Dev_role_full" {
  for_each = toset([
    "arn:aws-us-gov:iam::aws:policy/AWSCodeBuildDeveloperAccess", 
    "arn:aws-us-gov:iam::aws:policy/AWSCodeCommitPowerUser",
    "arn:aws-us-gov:iam::aws:policy/AWSCodeDeployFullAccess",
    "arn:aws-us-gov:iam::aws:policy/AWSCodePipeline_FullAccess"
  ])
  role       = var.iam_role_name
  policy_arn = each.value
}

################ 3rd way

resource "aws_iam_role" "Dev_role_full" {
  managed_policy_arns = ["arn:aws-us-gov:iam::aws:policy/AWSCodeBuildDeveloperAccess", 
 "arn:aws-us-gov:iam::aws:policy/AWSCodeCommitPowerUser",
 "arn:aws-us-gov:iam::aws:policy/AWSCodeDeployFullAccess",
 "arn:aws-us-gov:iam::aws:policy/AWSCodePipeline_FullAccess"]
  name               = "Dev_role_full"
  description        = "Dev full access for build deploy"
  assume_role_policy = data.aws_iam_policy_document.policy.json
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


### aws_kinesis_stream :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream)
- Provides a Kinesis Stream resource. Amazon Kinesis is a managed service that scales elastically for real-time processing of streaming big data.
```
resource "aws_kinesis_stream" "test_stream" {
  name             = "terraform-kinesis-test"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Environment = "test"
  }
}
```




### aws_kinesis_firehose_delivery_stream :
- [Terraform Doc Reff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream)
- Provides a Kinesis Firehose Delivery Stream resource. Amazon Kinesis Firehose is a fully managed, elastic service to easily deliver real-time data streams to destinations such as Amazon S3 and Amazon Redshift.
- Optional `prefix      = "source=aws/account=`
- Optional `kms_key_arn =`

```
resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "terraform-kinesis-firehose-extended-s3-test-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.bucket.arn

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        }
      }
    }
  }
}
```


### aws_sqs_queue :
- [Terraform Doc Ref](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue)
- AWS SNS Queue 

```
resource "aws_sqs_queue" "terraform_queue" {
  name                      = "terraform-example-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "production"
  }
}
```



### aws_sqs_queue_policy :
- [Terraform Doc Ref](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy)
- Allows you to set a policy of an SQS Queue while referencing ARN of the queue within the policy.
```
resource "aws_sqs_queue" "q" {
  name = "examplequeue"
}

resource "aws_sqs_queue_policy" "test" {
  queue_url = aws_sqs_queue.q.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.q.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.example.arn}"
        }
      }
    }
  ]
}
POLICY
}
```



### aws_db_instance :
- [Terraform Reff Doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)
- Provides an RDS instance resource. A DB instance is an isolated database environment in the cloud. A DB instance can contain multiple user-created databases.
```
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}
```




### aws_sfn_state_machine :
- [Terraform Reff Doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine)
- Provides a Step Function State Machine resource

```
resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "my-state-machine"
  role_arn = aws_iam_role.iam_for_sfn.arn

  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.lambda.arn}",
      "End": true
    }
  }
}
EOF
}
```



### aws_ssm_activation :
- [Terraform Reff Doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_activation)
- Registers an on-premises server or virtual machine with Amazon EC2 so that it can be managed using Run Command.

```
resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Allow",
      "Principal": {"Service": "ssm.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  }
EOF
}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_ssm_activation" "foo" {
  name               = "test_ssm_activation"
  description        = "Test"
  iam_role           = aws_iam_role.test_role.id
  registration_limit = "5"
  depends_on         = [aws_iam_role_policy_attachment.test_attach]
}
```



### aws_ssm_association :
- [Terraform Reff Doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association)
- Associates an SSM Document to an instance or EC2 tag.
- `apply_only_at_cron_interval` - (Optional)

```
resource "aws_ssm_association" "example" {
  name = aws_ssm_document.example.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.example.id]
  }
}
```



### aws_ssm_document :
- [Terraform Reff Doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document)
- Provides an SSM Document resource

```
resource "aws_ssm_document" "foo" {
  name          = "test_document"
  document_type = "Command"

  content = <<DOC
  {
    "schemaVersion": "1.2",
    "description": "Check ip configuration of a Linux instance.",
    "parameters": {

    },
    "runtimeConfig": {
      "aws:runShellScript": {
        "properties": [
          {
            "id": "0.aws:runShellScript",
            "runCommand": ["ifconfig"]
          }
        ]
      }
    }
  }
DOC
}
```



### aws_ssm_parameter :
- [Terraform Reff Doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter)
- Provides an SSM Parameter resource.

```
resource "aws_ssm_parameter" "foo" {
  name  = "foo"
  type  = "String"
  value = "bar"
}
```
- To store an encrypted string using the default SSM KMS key
```
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.16"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "foo"
  password             = var.database_master_password
  db_subnet_group_name = "my_database_subnet_group"
  parameter_group_name = "default.mysql5.7"
}

resource "aws_ssm_parameter" "secret" {
  name        = "/production/database/password/master"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.database_master_password

  tags = {
    environment = "production"
  }
}
```


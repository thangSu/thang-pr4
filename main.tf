provider "aws" {
  region = "us-east-1"
}
variable "bucket_name" {
  type = string
  default = "hcl-demo-test"
}

locals {
  map= {
    princilpals_dynamic = {
    "1"={
      type = "AWS"
      identifiers = ["704063666843"],
    }
    "2"={
      type = "AWS"
      identifiers = ["878103297030"],
    }
    }
     statement_dynamic = {
    "1" ={
       actions = ["s3:ListAllMyBuckets",]
       Effect = "Allow"
       resources = ["*",]
    }
    "2" ={
       actions = [ "s3:ListBucket",
                "s3:GetBucketLocation",]
        Effect = "Allow"
       resources = ["arn:aws:s3:::${var.bucket_name}",]
    }
    "3" ={
       actions = [  "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",]
        Effect = "Allow"
       resources = ["arn:aws:s3:::${var.bucket_name}/*",]
    }
    }
  }
}

data "aws_iam_policy_document" "ip_document" {
  statement {
    actions = ["sts:AssumeRole"]

    dynamic "principals" {
      for_each = local.map.princilpals_dynamic
      content {
        type        = principals.value.type
        identifiers = principals.value.identifiers
      } 
    }
  }
}
resource "aws_iam_role" "role" {
  name                = "ThangUpdateApp"
  assume_role_policy = data.aws_iam_policy_document.ip_document.json
  managed_policy_arns = [aws_iam_policy.ip.arn]
}

data "aws_iam_policy_document" "ip_document2" {

  dynamic "statement" {
    for_each = local.map.statement_dynamic

    content{
      actions = statement.value.actions
      Effect = statement.value.Effect
      resources = statement.value.resources
    }
  }
}
resource "aws_iam_policy" "ip" {
    name = "AccessRead"
    path = "/"
    description = "access to S3 bucket"

    policy = data.aws_iam_policy_document.ip_document2
}

resource "aws_iam_user" "iu" {
    name = "ThangAccess"
    path = "/system/"
}
resource "aws_iam_user_policy" "lb_ro" {
  name = "accessS3user"
  user = aws_iam_user.iu.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::704063666843:role/ThangUpdateApp"
    }
  }
EOF
}

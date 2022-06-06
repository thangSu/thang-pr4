provider "aws" {
  region = "us-east-1"
}
locals {
  map= {
    ip_dynamic= {
       "id1"={
      type = "AWS"
      identifiers = ["704063666843"],
    }
     "id2"={
      type = "AWS"
      identifiers = ["878103297030"],
    }
    }
  }
}

data "aws_iam_policy_document" "ip_document" {
  statement {
    actions = ["sts:AssumeRole"]

    dynamic "principals" {
      for_each = local.map.ip_dynamic
      content {
        type        = principals.value.type
        identifiers = principals.value.identifiers
      } 
    }
  }
}

resource "aws_iam_role" "example" {
  name                = "UpdateApp"
  assume_role_policy = data.aws_iam_policy_document.ip_document.json
  managed_policy_arns = [aws_iam_policy.ip.arn]
}


resource "aws_iam_policy" "ip" {
    name = "accessread"
    path = "/"
    description = "access to S3 bucket"

    policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Action": "s3:ListAllMyBuckets",
        "Resource": "*"
        },
        {
        "Effect": "Allow",
        "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation"
        ],
        "Resource": "arn:aws:s3:::thangdeptrai"
        },
        {
        "Effect": "Allow",
        "Action": [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
        ],
        "Resource": "arn:aws:s3:::thangdeptrai/*"
        }
    ]
    }
    )
}

resource "aws_iam_user" "iu" {
    name = "thangaccess"
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
      "Resource": "arn:aws:iam::704063666843:role/UpdateApp"
    }
  }
EOF
}

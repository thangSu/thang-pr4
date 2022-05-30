provider "aws" {
  region = "us-east-1"
}
resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.iu.name
  policy_arn = aws_iam_policy.ip.arn
}

resource "aws_iam_policy" "ip" {
    name = "access"
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
        "Resource": "arn:aws:s3:::productionapp"
        },
        {
        "Effect": "Allow",
        "Action": [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
        ],
        "Resource": "arn:aws:s3:::productionapp/*"
        }
    ]
    }
    )
}

resource "aws_iam_user" "iu" {
    name = "thangaccess"
    path = "/system/"
}

resource "aws_iam_role" "replication_role" {
  name = "terraform_replication_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "s3.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "replication_policy" {
  name        = "terraform_s3_replication_policy"
  description = "Policy for S3 cross-region replication"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::my-terraform-state-bucket-syd"  # Source bucket
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl"
        ],
        "Resource": [
          "arn:aws:s3:::my-terraform-state-bucket-syd/*"  # Objects in the source bucket
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:ReplicateObject",
          "s3:ReplicateDelete"
        ],
        "Resource": [
          "arn:aws:s3:::my-replication-destination-bucket/*"  # Destination bucket objects
        ]
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "replication_attachment" {
  role       = aws_iam_role.replication_role.name
  policy_arn = aws_iam_policy.replication_policy.arn
}

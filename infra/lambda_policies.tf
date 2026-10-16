resource "aws_iam_policy" "lambda_s3_raw_write" {
  name = "ModavivaLambdaS3RawWrite"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "WriteAnalyticsRaw"
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.analytics.arn}/raw/*"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_access" {
  name = "ModavivaLambdaAccess"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadRdsSecret"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = "arn:aws:secretsmanager:us-east-1:436847501474:secret:rds!db-2f0d7713-1438-449b-a12f-a8665311812b-lXPyeF"
      },
      {
        Sid    = "ManageVpcNetworkInterfaces"
        Effect = "Allow"

        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_curated_s3" {
  name = "ModavivaLambdaCuratedS3"
  role = aws_iam_role.lambda_curated.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ListAnalyticsBucket"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.analytics.arn
      },
      {
        Sid    = "ReadRawAnalyticsData"
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.analytics.arn}/raw/*"
      },
      {
        Sid    = "WriteCuratedAnalyticsData"
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.analytics.arn}/curated/*"
      }
    ]
  })
}
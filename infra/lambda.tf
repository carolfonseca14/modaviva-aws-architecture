resource "aws_lambda_function" "ingest" {
  function_name = "modaviva-lambda-ingest"

  package_type = "Image"
  image_uri    = "${aws_ecr_repository.lambda_ingest.repository_url}:v7"

  role        = aws_iam_role.lambda_ingest.arn
  memory_size = 256
  timeout     = 30

  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_group_ids = [
      aws_security_group.lambda.id
    ]
  }

  environment {
    variables = {
      ANALYTICS_BUCKET    = aws_s3_bucket.analytics.bucket
      DATABASE_NAME       = "postgres"
      DATABASE_HOST       = aws_db_instance.modaviva.address
      DATABASE_PORT       = "5432"
      DATABASE_SECRET_ARN = "arn:aws:secretsmanager:us-east-1:436847501474:secret:rds!db-2f0d7713-1438-449b-a12f-a8665311812b-lXPyeF"
    }
  }
}

resource "aws_lambda_function" "curated" {
  function_name = "modaviva-lambda-curated"

  package_type = "Image"
  image_uri    = "${aws_ecr_repository.lambda_curated.repository_url}:v3"

  role        = aws_iam_role.lambda_curated.arn
  memory_size = 512
  timeout     = 60

  environment {
    variables = {
      ANALYTICS_BUCKET = aws_s3_bucket.analytics.bucket
    }
  }
}
resource "aws_iam_role_policy_attachment" "lambda_s3_raw_write" {
  role       = aws_iam_role.lambda_ingest.name
  policy_arn = aws_iam_policy.lambda_s3_raw_write.arn
}

resource "aws_iam_role_policy_attachment" "lambda_access" {
  role       = aws_iam_role.lambda_ingest.name
  policy_arn = aws_iam_policy.lambda_access.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_ingest" {
  role       = aws_iam_role.lambda_ingest.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_curated" {
  role       = aws_iam_role.lambda_curated.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
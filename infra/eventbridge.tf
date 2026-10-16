resource "aws_scheduler_schedule" "lambda_ingest" {
  name                = "modaviva-lambda-ingest-schedule"
  schedule_expression = "rate(5 minutes)"
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.ingest.arn
    role_arn = aws_iam_role.eventbridge_scheduler.arn
  }
}
resource "aws_cloudwatch_dashboard" "operacional" {
  dashboard_name = "modaviva-operacional"

  dashboard_body = file("${path.module}/cloudwatch-dashboard.json")
}
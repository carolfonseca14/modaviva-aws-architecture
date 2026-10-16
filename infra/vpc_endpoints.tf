resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.modaviva.id
  service_name      = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true

}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.modaviva.id
  service_name      = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true

}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.modaviva.id
  service_name      = "com.amazonaws.us-east-1.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true

}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = aws_vpc.modaviva.id
  service_name      = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true

}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id            = aws_vpc.modaviva.id
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true

}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.modaviva.id
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true

}


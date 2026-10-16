resource "aws_security_group" "alb" {
  name        = "modaviva-alb-sg"
  description = "Security group for the ModaViva Application Load Balancer"
  vpc_id      = aws_vpc.modaviva.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "ecs" {
  name        = "modaviva-ecs-sg"
  description = "Security group for the ModaViva ECS application"
  vpc_id      = aws_vpc.modaviva.id

  ingress {
    protocol        = "tcp"
    from_port       = 8000
    to_port         = 8000
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "lambda" {
  name        = "modaviva-lambda-sg"
  description = "Security Group for ModaViva Lambda"
  vpc_id      = aws_vpc.modaviva.id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "rds" {
  name        = "modaviva-rds-sg"
  description = "Security group for the ModaViva RDS database"
  vpc_id      = aws_vpc.modaviva.id

  ingress {
    protocol  = "tcp"
    from_port = 5432
    to_port   = 5432
    security_groups = [
      aws_security_group.ecs.id,
      aws_security_group.lambda.id
    ]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "vpce" {
  name        = "modaviva-vpce-sg"
  description = "Security group for ModaViva VPC interface endpoints"
  vpc_id      = aws_vpc.modaviva.id

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    security_groups = [
      aws_security_group.ecs.id,
      aws_security_group.lambda.id
    ]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}


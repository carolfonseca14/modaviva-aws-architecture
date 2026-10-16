resource "aws_db_instance" "modaviva" {
  identifier = "modaviva-db"

  engine         = "postgres"
  engine_version = "18.3"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_encrypted = true

  username = "modaviva_admin"

  copy_tags_to_snapshot           = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  port = 5432

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  db_subnet_group_name = "default-vpc-04b8696a525bb6a3e"

  backup_retention_period = 1

  deletion_protection = false

  skip_final_snapshot = true
}

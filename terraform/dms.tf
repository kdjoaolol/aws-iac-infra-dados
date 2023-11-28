data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
module "database_migration_service" {
  source  = "terraform-aws-modules/dms/aws"
  version = "2.0.1"

  # Subnet group
  repl_subnet_group_name        = "example"
  repl_subnet_group_description = "DMS Subnet group"
  repl_subnet_group_subnet_ids  = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]


  # Instance
  repl_instance_apply_immediately      = true
  repl_instance_multi_az               = false
  repl_instance_class                  = "dms.t2.micro"
  repl_instance_id                     = "dmsInstance"
  repl_instance_publicly_accessible    = true
  repl_instance_vpc_security_group_ids = [aws_security_group.allow_mysql.id]

  endpoints = {
    source = {
      database_name               = aws_db_instance.default.db_name
      endpoint_id                 = "source-mysql-dms"
      endpoint_type               = "source"
      engine_name                 = aws_db_instance.default.engine
      username                    = aws_db_instance.default.username
      password                    = aws_db_instance.default.password
      port                        = 3306
      server_name                 = aws_db_instance.default.address
      ssl_mode                    = "none"
      tags                        = { EndpointType = "source" }
    }
  }

  s3_endpoints = {
    destination = {
      endpoint_id                 = "target-s3-landing-dms"
      endpoint_type               = "target"
      engine_name                 = "s3"
      extra_connection_attributes = "DataFormat=parquet;parquetVersion=PARQUET_2_0;"
      bucket_name                 = aws_s3_bucket_public_access_block.public_access_block[0].bucket # landing zone
      s3_settings = {
        bucket_folder           = "mysql-main-app"
        compression_type        = "GZIP"
        service_access_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/dms-s3-role"
        data_format             = "parquet"
      }
    }
  }

  replication_tasks = {
    s3_import = {
      replication_task_id = "mysqlToS3"
      migration_type      = "full-load"
      table_mappings      = file("configs/table_mappings.json")
      source_endpoint_key = "source"
      target_endpoint_key = "destination"
      tags                = { Task = "mysql-to-s3" }
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


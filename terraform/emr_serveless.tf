module "emr_studio" {
  source = "terraform-aws-modules/emr/aws//modules/studio"

  name                = "studio-emr"
  auth_mode           = "IAM"
  default_s3_location = "s3://example-s3-bucket/example"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.database_subnets[0], module.vpc.database_subnets[1], module.vpc.database_subnets[2]]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "emr_serverless" {
  source = "terraform-aws-modules/emr/aws//modules/serverless"

  name = "aplication-spark-jobs"

  release_label_prefix = "emr-6.6.0"

  initial_capacity = {
    driver = {
      initial_capacity_type = "Driver"

      initial_capacity_config = {
        worker_count = 1
        worker_configuration = {
          cpu    = "1 vCPU"
          memory = "2 GB"
        }
      }
    }

    executor = {
      initial_capacity_type = "Executor"

      initial_capacity_config = {
        worker_count = 1
        worker_configuration = {
          cpu    = "1 vCPU"
          disk   = "20 GB"
          memory = "2 GB"
        }
      }
    }
  }

  maximum_capacity = {
    cpu    = "2 vCPU"
    memory = "4 GB"
  }

  network_configuration = {
    subnet_ids = [module.vpc.database_subnets[0], module.vpc.database_subnets[1], module.vpc.database_subnets[2]]
  }

  security_group_name  = aws_security_group.allow_mysql.name

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
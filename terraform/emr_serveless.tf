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
    cpu    = "1 vCPU"
    memory = "2 GB"
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
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
          cpu    = "2 vCPU"
          memory = "10 GB"
        }
      }
    }

    executor = {
      initial_capacity_type = "Executor"

      initial_capacity_config = {
        worker_count = 2
        worker_configuration = {
          cpu    = "2 vCPU"
          disk   = "20 GB"
          memory = "10 GB"
        }
      }
    }
  }

  maximum_capacity = {
    cpu    = "16 vCPU"
    memory = "80 GB"
  }

  network_configuration = {
    subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  }

  security_group_name  = "SG-emr-serveless-aplication"

  security_group_rules = {
    egress_all = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
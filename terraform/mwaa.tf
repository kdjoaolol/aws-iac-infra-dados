output "instance_ip_addr" {
  value = aws_iam_role.mwaa_role.arn
}

module "mwaa" {
  source = "aws-ia/mwaa/aws"

  name               = "mwaa_infra"
  airflow_version    = "2.7.2"
  environment_class  = "mw1.small"
  create_s3_bucket   = false
  source_bucket_arn  = aws_s3_bucket.buckets[4].arn
  dag_s3_path        = "dags"
  create_iam_role    = false
  execution_role_arn = aws_iam_role.mwaa_role.arn
  ## If uploading requirements.txt or plugins, you can enable these via these options
  #plugins_s3_path      = "plugins.zip"
  #requirements_s3_path = "requirements.txt"


  logging_configuration = {
    dag_processing_logs = {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs = {
      enabled   = true
      log_level = "INFO"
    }

    task_logs = {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs = {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs = {
      enabled   = true
      log_level = "INFO"
    }
  }

  airflow_configuration_options = {
    "core.load_default_connections" = "false"
    "core.load_examples"            = "false"
    "webserver.dag_default_view"    = "tree"
    "webserver.dag_orientation"     = "TB"
  }

  min_workers        = 2
  max_workers        = 4
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  webserver_access_mode = "PUBLIC_ONLY"   # Choose the Private network option(PRIVATE_ONLY) if your Apache Airflow UI is only accessed within a corporate network, and you do not require access to public repositories for web server requirements installation
  source_cidr           = ["10.1.0.0/16"] # Add your IP address to access Airflow UI

}
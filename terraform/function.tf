module "lambda_function_in_vpc" {
  source = "terraform-aws-modules/lambda/aws"
  
  function_name = "populate-mysql"
  description   = "Function that creates and populates tables in mysql RDS"
  handler       = "simula_app.populate_mysql"
  runtime       = "python3.10"
  timeout       = 900

  source_path = "../src/lambda"

  vpc_subnet_ids         = module.vpc.public_subnets
  vpc_security_group_ids = [aws_security_group.allow_mysql.id]
  attach_network_policy  = true

    layers = [
    module.lambda_layer.lambda_layer_arn
  ]

    environment_variables = {
        DB_INSTANCE_ADDRESS            = aws_db_instance.default.address
        DB_USERNAME                    = aws_db_instance.default.username
        DB_PASSWORD                    = aws_db_instance.default.password
        DB_PORT                        = 3306
        DB_NAME                        = aws_db_instance.default.db_name
      }
  }

module "lambda_layer" {
  source = "terraform-aws-modules/lambda/aws"

  create_layer = true

  layer_name          = "python-dependencies"
  description         = "Lambda Layer with Python dependencies"
  compatible_runtimes = ["python3.10"]

  source_path = "../src/lambda_layer/python.zip"
}

# TRIGGER PARA RODAR A LAMBDA FUNCTION A CADA 1h
resource "aws_cloudwatch_event_rule" "every_hour" {
    name = "every-minute-jj"
    description = "Fires every hours"
    schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_hour" {
    rule = aws_cloudwatch_event_rule.every_hour.name
    target_id = module.lambda_function_in_vpc.lambda_function_name
    arn = module.lambda_function_in_vpc.lambda_function_arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = module.lambda_function_in_vpc.lambda_function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.every_hour.arn
}
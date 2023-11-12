resource "aws_iam_role" "cloudwatch_lambda" {
  name               = "${local.prefix}_Role_cloudwatch"
  path               = "/"
  description        = "Provides write permissions to CloudWatch Logs and S3 Full Access"
  assume_role_policy = file("./permissions/lambda_invoke_role.json")
}

resource "aws_iam_policy" "cloudwatch_lambda" {
  name        = "${local.prefix}_Policy_cloudwatch"
  path        = "/"
  description = "Permissão para o cloudwatch triggar a lambda function"
  policy      = file("./permissions/lambda_invoke_policy.json")
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.cloudwatch_lambda.name
  policy_arn = aws_iam_policy.cloudwatch_lambda.arn
}
# DMS 

resource "aws_iam_role" "s3_role" {
  name        = "dms-s3-role"
  description = "Role used to migrate data from S3 via DMS"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DMSS3"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "dms-s3-role"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "DMSS3"
          Action   = ["s3:*"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dmsvpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}

resource "aws_iam_role" "emr_serverless_spark" {
  name               = "${local.prefix}_Role_Emr_Serverless_s3_glue"
  path               = "/"
  description        = "Permissão para emr serverless acessar todos os recursos necessários"
  assume_role_policy = file("./permissions/emr_serverless_role.json")
}

resource "aws_iam_policy" "emr_serverless_spark" {
  name        = "${local.prefix}_Policy_Emr_Serverless_s3_glue"
  path        = "/"
  description = "Permissão para emr serverless acessar todos os recursos necessários"
  policy      = file("./permissions/emr_serverless_policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_s3.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}
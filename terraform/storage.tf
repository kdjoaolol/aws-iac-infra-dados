resource "aws_s3_bucket" "buckets" {
  count  = length(var.bucket_names)
  bucket = "${var.prefix}-${var.bucket_names[count.index]}"

  force_destroy = true
  tags = local.common_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  count  = length(var.bucket_names)
  bucket = "${var.prefix}-${var.bucket_names[count.index]}"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# resource "aws_s3_bucket_acl" "bucket_acl" {
#   count  = length(var.bucket_names)
#   bucket = "${var.prefix}-${var.bucket_names[count.index]}"
#   acl    = "private"
# }

# tirando o acesso ao publico
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count  = length(var.bucket_names)
  bucket = "${var.prefix}-${var.bucket_names[count.index]}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "jobs" {
  bucket = aws_s3_bucket_public_access_block.public_access_block[4].bucket
  key    = "jobs/"
  source = "/dev/null"
}

resource "aws_s3_object" "dag_mwaa" {
  bucket = aws_s3_bucket_public_access_block.public_access_block[4].bucket
  key    = "dags/"
  source = "/dev/null"
}

resource "aws_s3_object" "jars" {
  bucket = aws_s3_bucket_public_access_block.public_access_block[4].bucket
  key    = "jars/"
  source = "/dev/null"
}


resource "aws_s3_object" "jobs_object" {
  bucket = aws_s3_bucket_public_access_block.public_access_block[4].bucket
  key    = "jobs/Processador.py"
  source = "../src/jobs/pyspark/Processador.py"
}

resource "aws_s3_object" "jars_object" {
  bucket = aws_s3_bucket_public_access_block.public_access_block[4].bucket
  key    = "jars/delta-core_2.12-2.0.2.jar"
  source = "../src/jobs/jars/delta-core_2.12-2.0.2.jar"
}
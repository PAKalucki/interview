module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.6.0"

  bucket = "${var.prefix}-bucket-${var.region}"

  acl    = "private"

  force_destroy = true

  versioning = {
    enabled = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "test_files" {
  for_each = toset(["test_bad.json", "test_good.json"])
  bucket = module.s3_bucket.s3_bucket_id
  key    = "input/${each.key}"
  source = "files/${each.key}"
}
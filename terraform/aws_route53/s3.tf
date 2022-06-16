
resource "aws_s3_bucket" "hubdata" {
  bucket_prefix = "${var.prefix}-hubdata"
  tags = {
	Name = "${var.prefix}-hubdata"
  }
}

resource "aws_s3_bucket_versioning" "hubdata" {
  bucket = aws_s3_bucket.hubdata.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_acl" "hubdata" {
  bucket = aws_s3_bucket.hubdata.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "hubdata" {
  bucket                  = aws_s3_bucket.hubdata.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_policy" "access_from_hub" {
  bucket = aws_s3_bucket.hubdata.id
  policy = data.aws_iam_policy_document.access_from_hub.json
}

resource "aws_iam_user" "hub-s3" {
  name = "${var.prefix}-hub-s3"
  path = "/system/"

  tags = {
    Name = "${var.prefix}-hub-s3-user"
  }
}

data "aws_iam_policy_document" "access_from_hub" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.hub-s3.arn]
    }

    actions = [
      "s3:GetObject",
	  "s3:ListBucket",
	  "s3:PutObject",
	  "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.hubdata.arn,
      "${aws_s3_bucket.hubdata.arn}/*",
    ]
  }
}

resource "aws_iam_role" "ec2_s3_access_role" {
  count = var.use_iam_for_s3 == true ? 1 : 0
  name               = "s3-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Sid = ""
      }
    ]
  })
}

resource "aws_iam_policy" "s3_policy" {
  count = var.use_iam_for_s3 == true ? 1 : 0
  name        = "s3-policy"
  description = "Allow access to S3 for Hub"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Effect = "Allow",
            Action = [
                "s3:GetBucketLocation"
            ],
            Resource = [
                "arn:aws:s3:::*"
            ]
        },
        {
            Effect = "Allow",
            Action = [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:GetBucketAcl"
            ],
            Resource = [
                "${aws_s3_bucket.hubdata.arn}",
                "${aws_s3_bucket.hubdata.arn}/*"
            ]
        }
    ]
  })
}

resource "aws_iam_instance_profile" "s3_instance_profile" {   
  count = var.use_iam_for_s3 == true ? 1 : 0                          
  name  = "s3-instance-profile"                         
  role = "${aws_iam_role.ec2_s3_access_role[0].name}"
}

resource "aws_iam_policy_attachment" "s3-attach" {
  count = var.use_iam_for_s3 == true ? 1 : 0
  name       = "s3-attachment"
  roles      = ["${aws_iam_role.ec2_s3_access_role[0].name}"]
  policy_arn = "${aws_iam_policy.s3_policy[0].arn}"
}
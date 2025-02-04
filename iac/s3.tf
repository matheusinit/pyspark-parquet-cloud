resource "aws_s3_bucket" "amazon_sales" {
  bucket        = "amazon-sales"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "amazon_sales_policy_for_iam_user" {
  bucket = aws_s3_bucket.amazon_sales.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : aws_iam_user.amazon_sales_iam_user.arn
        },
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectAcl",
          "s3:PutObjectAcl"
        ],
        "Resource" : [
          "${aws_s3_bucket.amazon_sales.arn}",
          "${aws_s3_bucket.amazon_sales.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "amazon_sales_policy_for_iam_role" {
  bucket = aws_s3_bucket.amazon_sales.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : aws_iam_role.amazon_sales_iam_role.arn
        },
        "Action" : "s3:*",
        "Resource" : [
          "${aws_s3_bucket.amazon_sales.arn}",
          "${aws_s3_bucket.amazon_sales.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_object" "python_script" {
  bucket                 = aws_s3_bucket.amazon_sales.id
  key                    = "jobs/amazon_sales.py"
  source                 = "../amazon_sales.py"
  server_side_encryption = "AES256"
}

resource "aws_s3_object" "dataset" {
  bucket = aws_s3_bucket.amazon_sales.id
  key    = "dataset/amazon-sale-report.csv"
  source = "../data/Amazon Sale Report.csv"
}

resource "aws_s3_bucket" "amazon_sales" {
  bucket = "amazon-sales"
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
        "Action" : "s3:*",
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

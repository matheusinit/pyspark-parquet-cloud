resource "aws_iam_user" "amazon_sales_iam_user" {
  name = "amazon-sales-role"
}

resource "aws_iam_access_key" "amazon_sales_iam_access_key" {
  user = aws_iam_user.amazon_sales_iam_user.name
}

resource "aws_iam_role" "amazon_sales_iam_role" {
  name = "amazon-sales-iam-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      }
    ]
  })
}

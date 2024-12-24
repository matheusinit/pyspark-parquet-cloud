resource "aws_iam_user" "amazon_sales_iam_user" {
  name = "amazon-sales-iam-user"
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
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : aws_iam_user.amazon_sales_iam_user.arn
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_user_policy" "assume_role_policy" {
  name = "assume-role-policy"
  user = aws_iam_user.amazon_sales_iam_user.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Resource" : aws_iam_user.amazon_sales_iam_user.arn
      }
    ]
  })
}

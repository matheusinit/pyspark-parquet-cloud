resource "aws_iam_user" "amazon_sales_iam_user" {
  name = "amazon-sales-iam-user"
}

resource "aws_iam_access_key" "amazon_sales_iam_access_key" {
  user = aws_iam_user.amazon_sales_iam_user.name

  lifecycle {
    create_before_destroy = true
  }
}

output "access_key_id" {
  value = aws_iam_access_key.amazon_sales_iam_access_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.amazon_sales_iam_access_key.secret
  sensitive = true
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

  depends_on = [aws_iam_access_key.amazon_sales_iam_access_key]
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

resource "aws_iam_role_policy_attachment" "amazon_sales_iam_role_policy_attachment" {
  role       = aws_iam_role.amazon_sales_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "amazon_sales_instance_profile" {
  name = "amazon-sales-instance-profile"
  role = aws_iam_role.amazon_sales_iam_role.name
}

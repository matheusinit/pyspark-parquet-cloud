resource "aws_emr_cluster" "amazon_sales_spark_cluster" {
  name          = "amazon-sales-spark-cluster"
  release_label = "emr-7.5.0"
  applications  = ["Spark", "Hadoop"]

  service_role = aws_iam_role.iam_emr_service_role.arn

  ec2_attributes {
    instance_profile                  = aws_iam_instance_profile.amazon_sales_instance_profile.arn
    subnet_id                         = aws_subnet.amazon_sales_subnet_public1_us_west_2a.id
    key_name                          = aws_key_pair.emr_key_pair.key_name
    emr_managed_master_security_group = aws_security_group.emr_master_security_group.id
    emr_managed_slave_security_group  = aws_security_group.emr_slave_security_group.id
  }

  master_instance_group {
    instance_type  = "m1.medium"
    instance_count = 1
    name           = "Master Instance Group"
  }

  core_instance_group {
    instance_type  = "m1.medium"
    instance_count = 3
    name           = "Core Instance Group"
  }

  log_uri = "s3://amazon-sales/logs/"

  configurations_json = <<EOF
  [
    {
      "Classification": "yarn-site",
      "Properties": {
        "yarn.scheduler.maximum-allocation-mb": "4096",
        "yarn.nodemanager.resource.memory-mb": "4096"
      }
    },
    {
      "Classification": "hadoop-env",
      "Properties": {
        "hadoop.log.dir": "/var/log/hadoop" 
      }
    },
    {
      "Classification": "spark-defaults",
      "Properties": {
        "spark.log.level": "INFO" 
      }
    },
    {
      "Classification": "hadoop-log4j",
      "Properties": {
        "hadoop.root.logger": "INFO, console, rollingFile" 
      }
    }
  ]
  EOF
}

resource "aws_key_pair" "emr_key_pair" {
  key_name   = "amazon-sales-key-pair"
  public_key = tls_private_key.ec2_private_key.public_key_openssh
}

resource "tls_private_key" "ec2_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ec2_private_key_local" {
  filename        = "amazon-sales-key.pem"
  content         = tls_private_key.ec2_private_key.private_key_pem
  file_permission = "0400"
}

data "aws_iam_policy_document" "emr_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_emr_service_role" {
  name               = "iam_emr_service_role"
  assume_role_policy = data.aws_iam_policy_document.emr_assume_role.json
}

data "aws_iam_policy_document" "iam_emr_service_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CancelSpotInstanceRequests",
      "ec2:CreateNetworkInterface",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteNetworkInterface",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteTags",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribePrefixLists",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotInstanceRequests",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeVpcs",
      "ec2:DetachNetworkInterface",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:RequestSpotInstances",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:DeleteVolume",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListInstanceProfiles",
      "iam:ListRolePolicies",
      "iam:PassRole",
      "s3:CreateBucket",
      "s3:Get*",
      "s3:List*",
      "sdb:BatchPutAttributes",
      "sdb:Select",
      "sqs:CreateQueue",
      "sqs:Delete*",
      "sqs:GetQueue*",
      "sqs:PurgeQueue",
      "sqs:ReceiveMessage",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "iam_emr_service_policy" {
  name   = "iam_emr_service_policy"
  role   = aws_iam_role.iam_emr_service_role.id
  policy = data.aws_iam_policy_document.iam_emr_service_policy.json
}

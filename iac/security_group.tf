data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "emr_master_security_group" {
  name        = "emr-master-security-group"
  description = "Security Group for EMR Master Cluster"
  vpc_id      = aws_vpc.amazon_sales_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  revoke_rules_on_delete = true
}

resource "aws_security_group" "emr_slave_security_group" {
  name        = "emr-slave-security-group"
  description = "Security Group for EMR Slave Cluster"
  vpc_id      = aws_vpc.amazon_sales_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  revoke_rules_on_delete = true
}

resource "aws_security_group_rule" "inbound_rule_for_emr_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.emr_master_security_group.id
  source_security_group_id = aws_security_group.emr_slave_security_group.id
}

resource "aws_security_group_rule" "inbound_rule_for_aws_services" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  prefix_list_ids   = ["pl-45a6432c"]
  security_group_id = aws_security_group.emr_master_security_group.id
}

resource "aws_security_group_rule" "inbound_rule_for_emr_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.emr_slave_security_group.id
  source_security_group_id = aws_security_group.emr_master_security_group.id
}

resource "aws_security_group_rule" "inbound_ssh_rule_for_emr_master" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.emr_master_security_group.id
  cidr_blocks       = ["${chomp(data.http.myip.response_body)}/32"]
}

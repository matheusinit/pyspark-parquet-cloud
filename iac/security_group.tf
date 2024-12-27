data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "emr_master_security_group" {
  name        = "emr-master-security-group"
  description = "Security Group for EMR Master Cluster"
  vpc_id      = aws_vpc.amazon_sales_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  ingress {
    from_port   = 443 # Allow HTTPS connections (for console access)
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound traffic to anywhere
  }
}

resource "aws_security_group" "emr_slave_security_group" {
  name        = "emr-slave-security-group"
  description = "Security Group for EMR Slave Cluster"
  vpc_id      = aws_vpc.amazon_sales_vpc.id

  ingress {
    from_port   = 22 # Allow SSH connections
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  ingress {
    from_port   = 443 # Allow HTTPS connections (for console access)
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound traffic to anywhere
  }
}

resource "aws_security_group_rule" "inbound_rule_for_emr_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.emr_slave_security_group.id
  security_group_id        = aws_security_group.emr_master_security_group.id

  depends_on = [aws_security_group.emr_slave_security_group]
}

resource "aws_security_group_rule" "inbound_rule_for_emr_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.emr_master_security_group.id
  security_group_id        = aws_security_group.emr_slave_security_group.id

  depends_on = [aws_security_group.emr_master_security_group]
}

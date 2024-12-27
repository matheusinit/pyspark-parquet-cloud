resource "aws_vpc" "amazon_sales_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "amazon-sales-vpc"
  }
}

resource "aws_subnet" "amazon_sales_subnet_public1_us_west_2a" {
  vpc_id            = aws_vpc.amazon_sales_vpc.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "us-west-2a"

  tags = {
    Name = "amazon-sales-subnet-public1-us-west-2a"
  }
}

resource "aws_subnet" "amazon_sales_subnet_public2_us_west_2b" {
  vpc_id            = aws_vpc.amazon_sales_vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "us-west-2b"

  tags = {
    Name = "amazon-sales-subnet-public2-us-west-2b"
  }
}

resource "aws_internet_gateway" "amazon_sales_igw" {
  vpc_id = aws_vpc.amazon_sales_vpc.id

  tags = {
    Name = "amazon-sales-igw"
  }
}

resource "aws_route_table" "amazon_sales_rtb_public" {
  vpc_id = aws_vpc.amazon_sales_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.amazon_sales_igw.id
  }

  tags = {
    Name = "amazon-sales-rtb-public"
  }
}

resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.amazon_sales_subnet_public1_us_west_2a.id
  route_table_id = aws_route_table.amazon_sales_rtb_public.id
}

resource "aws_route_table_association" "amazon_sales_public2_route_table_association" {
  subnet_id      = aws_subnet.amazon_sales_subnet_public2_us_west_2b.id
  route_table_id = aws_route_table.amazon_sales_rtb_public.id
}

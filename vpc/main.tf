resource "aws_vpc" "test" {

    cidr_block = var.cidr
    tags = {
        Name = var.vpc-name
    }
}
resource "aws_subnet" "test-subnet" {
    vpc_id = aws_vpc.test.id
    cidr_block = var.subnet_cidr_block[count.index]
    count = 2
    map_public_ip_on_launch = true
    availability_zone = var.az[count.index]
    tags = {
        Name = var.subnet_name[count.index]
    }
}
resource "aws_subnet" "test2-subnet" {
    vpc_id = aws_vpc.test.id
    cidr_block = var.subnet_cidr_block2[count.index]
    count = 2
    map_public_ip_on_launch = false
    availability_zone = var.az2[count.index]
    tags = {
        Name = var.subnet_name2[count.index]
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = var.igw-name
  }
}
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block = var.route-gw
     gateway_id = aws_internet_gateway.igw.id
  }
    tags = {
    Name = var.igw-route-name
  }

}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.test-subnet[0].id
  route_table_id = aws_route_table.example.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.test-subnet[1].id
  route_table_id = aws_route_table.example.id
}


resource "aws_eip" "bar" {
  vpc = true
  depends_on                = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.bar.id
  subnet_id     = aws_subnet.test-subnet[0].id

  tags = {
    Name = var.nat-gw-name
  }

  depends_on = [aws_internet_gateway.igw]
}
resource "aws_route_table" "test-route" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block = var.route-gw
    gateway_id = aws_nat_gateway.example.id
  }
  tags = {
    Name = var.nat-route-name
  }
}
resource "aws_route_table_association" "x" {
  subnet_id      = aws_subnet.test2-subnet[0].id
  route_table_id = aws_route_table.test-route.id
}

resource "aws_route_table_association" "y" {
  subnet_id      = aws_subnet.test2-subnet[1].id
  route_table_id = aws_route_table.test-route.id
}

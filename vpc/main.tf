resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr

  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "myvpc_sub" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
      Name = "myvpc_sub"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myvpc.id

    tags = {
      Name = "myvpc_igw"
    }
}

resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
      Name = "myvpc_rt"
    }
}

resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.myvpc_sub.id
    route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "websg" {
  name        = "websg"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "websg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_http" {
  security_group_id = aws_security_group.websg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80  
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_http_8080" {
  security_group_id = aws_security_group.websg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_ssh" {
  security_group_id = aws_security_group.websg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22  
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "egress_rule_all" {
  security_group_id = aws_security_group.websg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_instance" "webserver1" {
    ami = "ami-0866a3c8686eaeeba"
    instance_type = "t2.micro"
    key_name = "aws-keypair-1"
    vpc_security_group_ids = [ aws_security_group.websg.id ]
    subnet_id = aws_subnet.myvpc_sub.id
    user_data = "${file("install_jenkins.sh")}"
        tags = {
      Name = "jenkins_instance"
      Project = "jenkins"
    }
}

/*
resource "aws_subnet" "myvpc_sub2" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}

resource "aws_route_table_association" "rta2" {
    subnet_id = aws_subnet.myvpc_sub2.id
    route_table_id = aws_route_table.rt.id
}

resource "aws_instance" "webserver2" {
    ami = "ami-0866a3c8686eaeeba"
    instance_type = "t2.micro"
    key_name = "aws-keypair-1"
    vpc_security_group_ids = [ aws_security_group.websg.id ]
    subnet_id = aws_subnet.myvpc_sub2.id
    user_data = "${file("install_nginx.sh")}"
}
*/


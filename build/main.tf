
data "aws_vpc" "selected" {
  filter {
    name = "tag:Name"
    values = ["${var.vpc}"]
  }
}

data "aws_subnets" "selected_subnet" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name = "tag:Name"
    values = ["${var.vpc_sub}"]
  }
}

output "subnet_id" {
  value = element(data.aws_subnets.selected_subnet.ids, 0)
}


resource "aws_security_group" "build_sg" {
  name        = "build_sg"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "build_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_http" {
  security_group_id = aws_security_group.build_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80  
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_http_8080" {
  security_group_id = aws_security_group.build_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_ssh" {
  security_group_id = aws_security_group.build_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22  
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "egress_rule_all" {
  security_group_id = aws_security_group.build_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "build_instance" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    key_name = var.mykey
    vpc_security_group_ids = [ aws_security_group.build_sg.id ]
    subnet_id = "${element(data.aws_subnets.selected_subnet.ids, 0)}"

    tags = {
      Name = "build_instance"
      Project = "build"
    }

    user_data = "${file("install_build_tools.sh")}"
}



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


resource "aws_security_group" "kind_sg" {
  name        = "kind_sg"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "kind_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_http" {
  security_group_id = aws_security_group.kind_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80  
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_http_8080" {
  security_group_id = aws_security_group.kind_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_ssh" {
  security_group_id = aws_security_group.kind_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22  
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "egress_rule_all" {
  security_group_id = aws_security_group.kind_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "kind_instance" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    key_name = "aws-keypair-1"
    vpc_security_group_ids = [ aws_security_group.kind_sg.id ]
    subnet_id = "${element(data.aws_subnets.selected_subnet.ids, 0)}"

    tags = {
      Name = "kind_instance"
      Project = "kind"
    }

    user_data = "${file("install_docker.sh")}"
}

/*
resource "aws_instance" "kind_workernode01" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    key_name = "aws-keypair-1"
    vpc_security_group_ids = [ aws_security_group.kind_sg.id ]
    subnet_id = "${element(data.aws_subnets.selected_subnet.ids, 0)}"
    
    tags = {
      Name = "kind_workernode01"
      Project = "kind"
    }

    user_data = "${file("install_docker.sh")}"
}
*/

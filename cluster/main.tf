terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

#
# Network creation 
#

resource "aws_vpc" "cka" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
        Name = "cka"
    }
}

resource "aws_internet_gateway" "cka-igw" {
    vpc_id = aws_vpc.cka.id 

    tags = {
        Name = "cka"
    }
}

resource "aws_subnet" "cka-public" {
    vpc_id = aws_vpc.cka.id 
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true

    tags = {
        Name = "cka-public"
    }
}

resource "aws_route_table" "cka-public" {
    vpc_id = aws_vpc.cka.id 

    tags = {
        Name = "cka-public"
    }
}

resource "aws_route_table_association" "cka-public" {
    subnet_id = aws_subnet.cka-public.id
    route_table_id = aws_route_table.cka-public.id
}

resource "aws_route" "cka-public-to-internet" {
    route_table_id = aws_route_table.cka-public.id 
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cka-igw.id
}

resource "aws_security_group" "allow-ssh" {
    name = "allow_ssh"
    description = "Allow SSH inbound traffic"
    vpc_id = aws_vpc.cka.id 

    ingress {
        description      = "SSH from VPC and Me"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = [aws_vpc.cka.cidr_block, "0.0.0.0/0"] # allow all for now
        # ipv6_cidr_blocks = [aws_vpc.cka.ipv6_cidr_block]
    }

    ingress {
        description      = "All from VPC and Me"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = [aws_vpc.cka.cidr_block, "0.0.0.0/0"] # allow all for now
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "allow_ssh"
    }
}

#
# Cluster creation
#

resource "aws_instance" "cka-master-1" {
    ami = var.server-ami
    instance_type = var.server-instance-type
    key_name = "cka"
    subnet_id = aws_subnet.cka-public.id
    vpc_security_group_ids = [ aws_security_group.allow-ssh.id ]

    tags = {
        Name = "cka-master-1"
    }
}

resource "aws_instance" "cka-worker-1" {
    ami = var.server-ami
    instance_type = var.server-instance-type
    key_name = "cka"
    subnet_id = aws_subnet.cka-public.id
    vpc_security_group_ids = [ aws_security_group.allow-ssh.id ]

    tags = {
        Name = "cka-worker-1"
    }
}

resource "aws_instance" "cka-worker-2" {
    ami = var.server-ami
    instance_type = var.server-instance-type
    key_name = "cka"
    subnet_id = aws_subnet.cka-public.id
    vpc_security_group_ids = [ aws_security_group.allow-ssh.id ]

    tags = {
        Name = "cka-worker-2"
    }
}
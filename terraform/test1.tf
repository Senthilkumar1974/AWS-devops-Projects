// VPC Creation
// provider 
provider "aws" {
  region = "ap-northeast-1"
}

//Aws VPC 
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraformvpc"
  }
  
}

//subnet -Public
resource "aws_subnet" "pubsubnet" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "${aws_vpc.myvpc.vpc_id}"
  tags = {
    Name = "publicsubnet"
  }
}

//Subnet - Private
resource "aws_subnet" "privsubnet" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "privatesubnet"
  }
}

// Internet Gat way
resource "aws_internet_gateway" "tigw" {
  vpc_id = "${aws_vpc.myvpc.id}"

  tags = {
    Name = "IGW"
  }
}

//Route Table - Public
resource "aws_route_table" "pubrt" {
 vpc_id = "${aws_vpc.myvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tigw.id}"
  }

   tags = {
    Name = "publicRT"
  } 
}

////Route Table - Public Association
resource "aws_route_table_association" "pubRTassociation" {

  subnet_id      = "${aws_subnet.pubsubnet.id}"
  route_table_id = "${aws_route_table.pubrt.id}" 
}
//elastic ip
resource  "aws_eip" "eip" {
    vpc      = true
}
  

//Nat gateway
resource "aws_nat_gateway" "tnat" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id     = "${aws_subnet.pubsubnet.id}"
}

////Route Table - Private
resource "aws_route_table" "pvtrt" {
 vpc_id = "${aws_vpc.myvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.tnat.id}"
  }

   tags = {
    Name = "privateRT"
  } 
}

////Route Table - Private - Association
resource "aws_route_table_association" "privateRTassociation" {

  subnet_id      = "${aws_subnet.privsubnet.id}"
  route_table_id = "${aws_route_table.pvtrt.id}" 
}
//------------------------
//security group
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "allow_all inbound traffic"
  vpc_id      = "${aws_vpc.myvpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//-------------------------------

resource "aws_instance" "Jumpbox" {
    ami             = "ami-0992fc94ca0f1415a"
  instance_type     = "t2.micro"
  subnet_id         = "${aws_subnet.pubsubnet.id}"
  key_name          = "EC2tokyo"
  vpc_security_group_ids=[ "${aws_security_group.allow_all.id}"]
  associate_public_ip_address = true

}

resource "aws_instance" "private" {
    ami             = "ami-0992fc94ca0f1415a"
  instance_type     = "t2.micro"
  subnet_id         = "${aws_subnet.privsubnet.id}"
  key_name          = "EC2tokyo"
  vpc_security_group_ids=[ "${aws_security_group.allow_all.id}"]

}

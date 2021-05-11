
resource "aws_instance" "myec2" {
         ami = "ami-0bcf5425cdc1d8a85"
         
        instance_type     = "t2.micro"
        }

provider "aws" {
    region = "ap-south-1"
    access_key = "AKIA5E5ABKTCRFYH4K62"
    secret_key = "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"
}

/// change instance type
resource "aws_instance" "myec2" {
         ami = "ami-0bcf5425cdc1d8a85"
        instance_type     = "t2.nano"
        }

// security_group
resource "aws_security_group" "demo_var" {
    name        = "demo_var"

    ingress {
        description = "TLS from VPC"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["10.20.30.40/32"]
         }

    ingress {
        description = "TLS from VPC"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["10.20.30.40/32"]
        }

    ingress {
        description = "TLS from VPC"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.20.30.40/32"]
        }

 
}


// declarevvariable
variable "client_ip " {
 default = "10.30.40.50/32"
}

// elasticip
resource "aws_eip" "myeip" {
 vpc = true
}
// output - particular attribute ex:public_ip
output "demo_outputeip"{
value = aws_eip.myeip.public_ip
}

// output - all attributes assigned
output "demo_outputeip"{
value = aws_eip.myeip
}

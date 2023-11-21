terraform {
  backend "s3" {
    bucket = "aramis-aws-terraform-remote-state-dev"
    key    = "ec2/ec2provider.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = var.region
}


#Criando VPC
resource "aws_vpc" "vpc_LAB" {
    cidr_block =  var.network_cidr
    enable_dns_hostnames = true
}
# Criando duas subredes em zonas de disponibilidade diferentes
resource "aws_subnet" "Subnet_LAB" {
  count           = var.subnet_count
  vpc_id          = aws_vpc.vpc_LAB.id
  cidr_block      = cidrsubnet(var.network_cidr, 8, count.index)
  availability_zone = element(["us-east-2a", "us-east-2b"], count.index % 2)
}
#Adicionando internet gateway
  resource "aws_internet_gateway" "Gateway_LAB" {
  vpc_id = aws_vpc.vpc_LAB.id
}


# Criando uma Tabela de rotas ja associando o internet gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_LAB.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Gateway_LAB.id
  }
}


#Associando a tabela de rotas as duas subnets e definindo a criação do IG como depenencia
resource "aws_route_table_association" "public_subnet" {
  count = length(aws_subnet.Subnet_LAB)
  subnet_id      = aws_subnet.Subnet_LAB[count.index].id
  route_table_id = aws_route_table.public.id
  depends_on     = [aws_internet_gateway.Gateway_LAB]
}
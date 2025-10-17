terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = var.yandex_zone
}

locals {
  vpc_name     = "${var.env_name}-${var.vpc_name}"
  cluster_name = "${var.cluster_name}-${var.env_name}"
}

## Определение Yandex VPC

resource "yandex_vpc_network" "main" {
  name = local.vpc_name
  # cidr_block = var.main_vpc_cidr
  # tag = {
  #   "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  # }
}

## !! нет аналога "aws_availability_zones" в Yandex Cloud

# Интернет-шлюз и таблицы маршрутизации для общедоступных подсетей

resource "yandex_vpc_gateway" "igw" {
  name = "${local.vpc_name}-igw"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "public-route" {
  name = "${local.vpc_name}-public-route"
  network_id = yandex_vpc_network.main.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.igw.id
  }
}

# 

resource "yandex_vpc_address" "nat-a" {
  name = "${local.vpc_name}-NAT-a"
  external_ipv4_address {
    zone_id = "ru-central1-d"
  }
}

resource "yandex_vpc_address" "nat-b" {
  name = "${local.vpc_name}-NAT-b"
  external_ipv4_address {
    zone_id = "ru-central1-b"
  }
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "${local.vpc_name}-nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private-route" {
  name = "${local.vpc_name}-private-route"
  network_id = yandex_vpc_network.main.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.nat_gateway.id
  }
}

# Определение подсети

resource "yandex_vpc_subnet" "public-subnet-a" {
  name           = "${local.vpc_name}-public-subnet-a"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_a_cidr]
  route_table_id = yandex_vpc_route_table.public-route.id
  # tags = {
  #   "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  #   "kubernetes.io/role/elb"                      = "1"
  # }
}

resource "yandex_vpc_subnet" "public-subnet-b" {
  name           = "${local.vpc_name}-public-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_b_cidr]
  route_table_id = yandex_vpc_route_table.public-route.id
  # tags = {
  #   "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  #   "kubernetes.io/role/elb"                      = "1"
  # }
}

resource "yandex_vpc_subnet" "private-subnet-a" {
  name           = "${local.vpc_name}-private-subnet-a"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_a_cidr]
  route_table_id = yandex_vpc_route_table.private-route.id
  # tags = {
  #   "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  #   "kubernetes.io/role/internal-elb"             = "1"
  # }
}

resource "yandex_vpc_subnet" "private-subnet-b" {
  name           = "${local.vpc_name}-private-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_b_cidr]
  route_table_id = yandex_vpc_route_table.private-route.id
  # tags = {
  #   "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  #   "kubernetes.io/role/internal-elb"             = "1"
  # }
}

#  ...
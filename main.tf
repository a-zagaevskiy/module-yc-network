terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}


provider "yandex" {
  zone = "ru-central1-d"
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

# Определение подсети

## нет аналога "aws_availability_zones" в Yandex Cloud

resource "yandex_vpc_subnet" "public-subnet-a" {
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_a_cidr]
  zone           = "ru-central1-d"
  name           = "${local.vpc_name}-public-subnet-a"
  # tags = {
  #   "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  #   "kubernetes.io/role/elb"                      = "1"
  # }
}

resource "yandex_vpc_subnet" "public-subnet-b" {
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_b_cidr]
  zone           = "ru-central1-b"
  name           = "${local.vpc_name}-public-subnet-b"
  # tags = {
  #   "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  #   "kubernetes.io/role/elb"                      = "1"
  # }
}

resource "yandex_vpc_subnet" "private-subnet-a" {
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_a_cidr]
  zone           = "ru-central1-d"
  name           = "${local.vpc_name}-private-subnet-a"
  # tags = {
  #   "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  #   "kubernetes.io/role/internal-elb"             = "1"
  # }
}

resource "yandex_vpc_subnet" "private-subnet-b" {
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_b_cidr]
  zone           = "ru-central1-b"
  name           = "${local.vpc_name}-private-subnet-b"
  # tags = {
  #   "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  #   "kubernetes.io/role/internal-elb"             = "1"
  # }
}

# Интернет-шлюз и таблицы маршрутизации для общедоступных подсетей

resource "yandex_vpc_gateway" "igw" {
  name = "${local.vpc_name}-igw"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "public-route" {
  network_id = yandex_vpc_network.main.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.igw.id
  }
  name = "${local.vpc_name}-public-route"
}

#  ...
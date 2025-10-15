output "vpc_id" {
  value = yandex_vpc_network.main.id
}

output "subnet_ids" {
  value = [
    yandex_vpc_subnet.public-subnet-a.id,
    yandex_vpc_subnet.public-subnet-b.id,
    yandex_vpc_subnet.private-subnet-a.id,
    yandex_vpc_subnet.private-subnet-b.id
  ]
}

output "pubic_subnet_ids" {
  value = [
    yandex_vpc_subnet.public-subnet-a.id,
    yandex_vpc_subnet.public-subnet-b.id
  ]
}

output "private_subnet_ids" {
  value = [
    yandex_vpc_subnet.private-subnet-a.id,
    yandex_vpc_subnet.private-subnet-b.id
  ]
}
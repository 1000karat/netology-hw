terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.181.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

############################
# Сеть
############################
resource "yandex_vpc_network" "network" {
  name = "lab-network"
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "lab-nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route_table" {
  name       = "lab-route-table"
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "lab-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.10.0.0/24"]
  route_table_id = yandex_vpc_route_table.route_table.id
}

############################
# Образы
############################
data "yandex_compute_image" "debian_12" {
  family = "debian-12"
}

############################
# Debian с внешним IP
############################
resource "yandex_compute_instance" "deb_srv" {
  name = "deb-srv" #Имя ВМ в облачной консоли
  hostname    = "deb-srv" #формирует FDQN имя хоста, без hostname будет сгенрировано случаное имя

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian_12.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet.id
    ip_address = "10.10.0.10"
    nat        = true
  }

  scheduling_policy {
    preemptible = true #прерывание
  }

  metadata = {
    user-data = file("${path.module}/meta.txt")
  }
}

############################
# Outputs
############################

output "deb_srv_public_ip" {
  value = yandex_compute_instance.deb_srv.network_interface[0].nat_ip_address
}
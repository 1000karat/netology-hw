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

# -------------------------
# Сеть
# -------------------------
resource "yandex_vpc_network" "network" {
  name = "web-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "web-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.10.10.0/24"]
}

# -------------------------
# VM 
# -------------------------
resource "yandex_compute_instance" "vm" {
  count = 1
  name  = "web-${count.index}"
  
  zone        = "ru-central1-a"
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 4
	core_fraction = 20 #% 20 50 100
  }

  boot_disk {
    initialize_params {
		type     = "network-hdd"
		size     = "10"
		#Debian 12
		image_id = "fd8a3ihrv5tf5ekfje6t"
		#Ubuntu
		#image_id = "fd82j5pd6sr11kid8ehh"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }
  
  #Прерываемые VM
  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = file("${path.module}/install.yml")
  }
}

output "external_ips" {
  description = "External IPs list"
  value = [
    for vm in yandex_compute_instance.vm :
    vm.network_interface[0].nat_ip_address
  ]
}
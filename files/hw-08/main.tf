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
# VM (2 штуки)
# -------------------------
resource "yandex_compute_instance" "vm" {
  count = 2
  name  = "web-${count.index}"
  
  zone        = "ru-central1-a"
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 1
	core_fraction = 5 #% 20 50 100
  }

  boot_disk {
    initialize_params {
		type     = "network-hdd"
		size     = "10"
		image_id = "fd82ovt5m620dqs3kai2"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }
  
  # Прерываемые VM
  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = file("${path.module}/install.yml")
  }
}

# -------------------------
# Target Group
# -------------------------
resource "yandex_lb_target_group" "tg" {
  name = "web-target-group"

  dynamic "target" {
    for_each = yandex_compute_instance.vm
    content {
      subnet_id = yandex_vpc_subnet.subnet.id
      address   = target.value.network_interface[0].ip_address
    }
  }
}

# -------------------------
# Network Load Balancer
# -------------------------
resource "yandex_lb_network_load_balancer" "nlb" {
  name = "web-nlb"

  listener {
    name = "http-listener"
    port = 80

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.tg.id

    healthcheck {
      name = "http-healthcheck"

      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
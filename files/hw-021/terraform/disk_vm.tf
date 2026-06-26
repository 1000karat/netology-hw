variable "set_disk_vm" {
  type = object({
    name = string,
    size = number,
    type = string
  })
  default = {
    name = "disk-vm",
    size = 1,
    type = "network-hdd"
  }
}

resource "yandex_compute_disk" "disk_vm" {
  count = 3

  name = "${var.set_disk_vm.name}-${count.index + 1}"
  size = var.set_disk_vm.size
  type = var.set_disk_vm.type
  zone = var.default_zone
}

variable "vm_resources_storage" {
  type = object({
    platform_id   = string,
    cores         = number,
    memory        = number,
    core_fraction = number,
    hdd_size      = number,
    hdd_type      = string,
    nat           = bool,
    preemptible   = bool
    image         = string
  })
  default = {
    platform_id   = "standard-v3",
    cores         = 2,
    memory        = 2,
    core_fraction = 20,
    hdd_size      = 10,
    hdd_type      = "network-hdd",
    nat           = true,
    preemptible   = true,
    image         = "debian-11"
  }
}

data "yandex_compute_image" "vm_image_storage" {
  family = var.vm_resources_storage.image
}

resource "yandex_compute_instance" "storage" {
  name        = "storage"
  hostname    = "storage"
  platform_id = var.vm_resources_storage.platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vm_resources_storage.cores
    memory        = var.vm_resources_storage.memory
    core_fraction = var.vm_resources_storage.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_image_storage.image_id
      size     = var.vm_resources_storage.hdd_size
    }
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.disk_vm

    content {
      disk_id = secondary_disk.value.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = var.vm_resources_storage.nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  scheduling_policy {
    preemptible = var.vm_resources_storage.preemptible
  }

  metadata = {
    ssh-keys = "storage:${local.ssh_public_key}"
  }
}
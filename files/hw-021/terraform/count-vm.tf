variable "vm_resources" {
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

data "yandex_compute_image" "vm_image" {
  family = var.vm_resources.image
}

resource "yandex_compute_instance" "web" {
  depends_on = [yandex_compute_instance.db]
  count       = 2
  name        = "web-${count.index + 1}"
  hostname    = "web-${count.index + 1}"
  platform_id = var.vm_resources.platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vm_resources.cores
    memory        = var.vm_resources.memory
    core_fraction = var.vm_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_image.image_id
      type     = var.vm_resources.hdd_type
      size     = var.vm_resources.hdd_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = var.vm_resources.nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  scheduling_policy {
    preemptible = var.vm_resources.preemptible
  }

  metadata = {
    ssh-keys = "deb-web-${count.index + 1}:${local.ssh_public_key}"
  }
}
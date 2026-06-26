variable "each_vm" {
  type = list(object({
    vm_name       = string,
    cpu           = number,
    memory        = number,
    core_fraction = number,
    hdd_type      = string,
    hdd_size      = number,
    platform_id   = string,
    nat           = bool,
    preemptible   = bool,
    image         = string
  }))

  default = [{
    vm_name       = "main"
    cpu           = 2
    memory        = 4
    core_fraction = 20
    hdd_type      = "network-hdd"
    hdd_size      = 10
    platform_id   = "standard-v3"
    nat           = true
    preemptible   = true
    image         = "debian-11"
    },
    {
      vm_name       = "replica"
      cpu           = 2
      memory        = 4
      core_fraction = 20
      hdd_type      = "network-hdd"
      hdd_size      = 10
      platform_id   = "standard-v3"
      nat           = true
      preemptible   = true
      image         = "debian-11"
  }]
}

data "yandex_compute_image" "db_image" {
  for_each = {
    for index, vm  in var.each_vm :
    vm.vm_name => vm
  }

  family = each.value.image
}

resource "yandex_compute_instance" "db" {
  for_each = {
    for index, vm in var.each_vm :
    vm.vm_name => vm
  }

  name        = each.value.vm_name
  hostname    = each.value.vm_name
  platform_id = each.value.platform_id

  resources {
    cores         = each.value.cpu
    memory        = each.value.memory
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.db_image[each.key].image_id
      type     = each.value.hdd_type
      size     = each.value.hdd_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = each.value.nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  scheduling_policy {
    preemptible = each.value.preemptible
  }

  metadata = {
    ssh-keys = "${each.key}:${local.ssh_public_key}"
  }
}
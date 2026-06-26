variable "set_disk_vm" {
  type = object({
    name = string,
    size = number,
    type = string
  })
  default = {
    name = "dosk-vm",
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
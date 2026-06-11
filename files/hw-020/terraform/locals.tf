locals {
  vm_names = {
    web = "${var.vpc_name}-${var.vm_web_family}-web"
    db  = "${var.vpc_name}-${var.vm_web_family}-db"
  }

  zones = {
    a = "ru-central1-a"
    b  = "ru-central1-b"
  }
}
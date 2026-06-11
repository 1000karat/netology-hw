#vars vm_web_
variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
  }))
}

variable "vms_metadata" {
  type = object({
    serial-port-enable = number
    ssh-user           = string
    ssh-key            = string
  })
}

variable "vm_web_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

/*variable "vm_web_name" {
  type    = string
  default = "netology-develop-platform-web"
}*/

variable "vm_web_platform_id" {
  type    = string
  default = "standard-v3"
}

/*variable "vm_web_cores" {
  type    = number
  default = 2
}

variable "vm_web_memory" {
  type    = number
  default = 1
}

variable "vm_web_core_fraction" {
  type    = number
  default = 20
}*/

variable "vm_web_preemptible" {
  type    = bool
  default = true
}

variable "vm_web_nat" {
  type    = bool
  default = true
}

/*variable "vm_db_name" {
  type    = string
  default = "netology-develop-platform-db"
}*/

variable "vm_db_platform_id" {
  type    = string
  default = "standard-v3"
}

/*variable "vm_db_cores" {
  type    = number
  default = 2
}

variable "vm_db_memory" {
  type    = number
  default = 2
}

variable "vm_db_core_fraction" {
  type    = number
  default = 20
}*/

variable "vm_db_preemptible" {
  type    = bool
  default = true
}
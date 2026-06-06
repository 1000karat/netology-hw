variable "docker_host" {
  description = "External IP of VM"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for VM"
  type        = string
  default     = "vm-ya-console"
}
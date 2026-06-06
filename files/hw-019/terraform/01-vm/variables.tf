variable "service_account_key_file" {
  description = "Path to service account key JSON file"
  type        = string
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

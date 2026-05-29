variable "vsphere_server" {}
variable "vsphere_user" {}
variable "vsphere_password" {
  sensitive = true
}

variable "datacenter" {}
variable "cluster" {}
variable "datastore" {}
variable "network" {}

variable "template_name" {}

variable "vm_name" {}
variable "vm_cpu" {
  default = 2
}
variable "vm_memory_mb" {
  default = 4096
}
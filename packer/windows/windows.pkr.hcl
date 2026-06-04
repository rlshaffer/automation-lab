packer {
  required_plugins {
    vsphere = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

variable "vsphere_user" { type = string }
variable "vsphere_password" { type = string }
variable "vsphere_server" { type = string }

variable "datacenter" { type = string }
variable "cluster" { type = string }
variable "datastore" { type = string }
variable "network" { type = string }

variable "template_name" { type = string }

variable "vm_cpu" {
  type    = number
  default = 2
}

variable "vm_memory_mb" {
  type    = number
  default = 4096
}

variable "win_admin_password" {
  type = string
}

source "vsphere-iso" "windows" {
  vcenter_server = var.vsphere_server
  username       = var.vsphere_user
  password       = var.vsphere_password

  datacenter = var.datacenter
  cluster    = var.cluster
  datastore  = var.datastore
  network    = var.network

  vm_name = var.template_name

  vm_cpu    = var.vm_cpu
  vm_memory = var.vm_memory_mb

  guest_os_type = "windows9Server64Guest"

  disk_controller_type = ["pvscsi"]

  storage {
    disk_size             = 40960
    disk_thin_provisioned = true
  }

}

build {
  sources = ["source.vsphere-iso.windows"]

  provisioner "powershell" {
    inline = [
      "Write-Host 'Configuring WinRM + firewall...'",

      "Set-NetConnectionProfile -NetworkCategory Private",

      "winrm quickconfig -q",
      "Enable-PSRemoting -Force",

      "winrm delete winrm/config/listener?Address=*+Transport=HTTP 2>$null",
      "winrm create winrm/config/listener?Address=*+Transport=HTTP",

      "Set-Service WinRM -StartupType Automatic",

      "Enable-NetFirewallRule -DisplayGroup \"Windows Remote Management\""
    ]
  }
}

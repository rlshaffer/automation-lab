packer {
  required_plugins {
    vsphere = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

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
  username = "admin.shaffer@nordsoncorp.local"
  password = var.vsphere_password
  datacenter = var.datacenter
  cluster    = var.cluster
  datastore  = var.datastore

  vm_name = var.template_name

  guest_os_type = "windows9Server64Guest"

   vm_version = 21

  firmware = "bios"

  CPUs = var.vm_cpu
  RAM  = var.vm_memory_mb

  network_adapters {
    network      = var.network
    network_card = "vmxnet3"
  }

  storage {
    disk_size             = 163840
    disk_thin_provisioned = true
  }
  iso_paths = [
    "[LABVMW_DATASTORE] Repository/SW_DVD9_Win_Server_STD_CORE_2025_24H2.1_64Bit_English_DC_STD_MLF_X23-89914.ISO", # Your main OS ISO
  ]
 
  disk_controller_type = ["lsilogic-sas"]
  cdrom_type           = "ide"
  boot_order           = "cdrom,disk"

  floppy_files = [
  "autounattend.xml",
  ]

 
  # ✅ HTTP server (key fix)
  http_directory = "./http"

  boot_wait = "2s" 

boot_wait = "5s"

boot_command = [
  "<spacebar>",
  "<spacebar>",
  "<spacebar>",
  "<spacebar>",
  "<enter>"
 
  ]

  communicator = "winrm"
  winrm_username = "Administrator"
  winrm_password = var.win_admin_password
  winrm_timeout  = "2h"

  insecure_connection = true
  set_host_for_datastore_uploads = true

}

build {
  sources = ["source.vsphere-iso.windows"]

  provisioner "powershell" {
    inline = [
      "Write-Host 'Configuring WinRM + firewall...'",
      "Set-NetConnectionProfile -NetworkCategory Private",
      "winrm quickconfig -q",
      "Enable-PSRemoting -Force",
      "winrm delete winrm/config/listener?Address=*+Transport=HTTP 2> $null",
      "winrm create winrm/config/listener?Address=*+Transport=HTTP",
      "Set-Service WinRM -StartupType Automatic",
      "Enable-NetFirewallRule -DisplayGroup \"Windows Remote Management\""
    ]
  }
}
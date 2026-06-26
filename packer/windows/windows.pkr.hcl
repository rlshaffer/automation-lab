packer {
  required_plugins {
    vsphere = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/vsphere"
    }

    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}
variable "vsphere_user"      { type = string }
variable "vsphere_password"  { type = string }
variable "vsphere_server"    { type = string }
variable "datacenter"        { type = string }
variable "cluster"           { type = string }
variable "datastore"         { type = string }
variable "network"           { type = string }
variable "template_name"     { type = string }
variable "vm_admin_password" { type = string }

variable "vm_cpu" {
  type    = number
  default = 2
}

variable "vm_memory_mb" {
  type    = number
  default = 4096
}

source "vsphere-iso" "windows" {
  vcenter_server      = var.vsphere_server
  username            = var.vsphere_user # Switched from hardcoded string to variable
  password            = var.vsphere_password
  datacenter          = var.datacenter
  cluster             = var.cluster
  datastore           = var.datastore
  insecure_connection = true

  vm_name       = var.template_name
  guest_os_type = "windows9Server64Guest" # Standard vSphere identifier
  vm_version    = 21
  firmware      = "efi"
  cdrom_type    = "sata"

  CPUs = var.vm_cpu
  RAM  = var.vm_memory_mb

  network_adapters {
    network      = var.network
    network_card = "vmxnet3"
  }

  # Upgraded to high-performance VMware Paravirtual SCSI
  disk_controller_type = ["pvscsi"]

  storage {
    disk_size             = 163840
    disk_thin_provisioned = true
  }

  # Map BOTH the OS installation media and the ESXi native VMware Tools package
  iso_paths = [
    "[LABVMW_DATASTORE] Repository/SW_DVD9_Win_Server_STD_CORE_2025_24H2.1_64Bit_English_DC_STD_MLF_X23-89914.ISO", # Your main OS ISO
    "[Iso Data Store] vmware_iso/Windows10.iso" 
  ]

  # CRITICAL: We move the answer file to a secondary CD-ROM so EFI reads it
  cd_content = {
    "autounattend.xml" = file("${path.root}/autounattend.xml")
  }
  cd_label = "cidata"

  boot_order = "cdrom,disk"
  boot_wait  = "2s"

  boot_command = [
    "<spacebar><spacebar><spacebar>"
  ]

  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_password = var.vm_admin_password
  winrm_timeout  = "2h"

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
      "Set-Service WinRM -StartupType Automatic",
      "Enable-NetFirewallRule -DisplayGroup 'Windows Remote Management'"
    ]
  }
}

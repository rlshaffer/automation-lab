# Packer + AWX vSphere Gold Image Pipeline

## Overview
This pipeline builds and uses a **gold image** for Windows Server in vSphere using:

- Packer → Build template
- Terraform → Deploy VM
- Ansible/AWX → Configure

---

## Architecture

Packer → Template → Terraform → VM → Ansible

---

## Repository Structure

automation-lab/
├── packer/
│   ├── packer
│   ├── run_packer.yml
│   └── windows/
│       └── windows.pkr.hcl
├── docs/
│   └── packer-awx-gold-image.md

---

## Packer Template (Secure Version)

variable "vsphere_user" {
  type = string
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

source "vsphere-iso" "windows" {
  vcenter_server = var.vsphere_server

  username = var.vsphere_user
  password = var.vsphere_password

  datacenter = var.datacenter
  cluster    = var.cluster
  datastore  = var.datastore

  vm_name = var.template_name

  CPUs = var.vm_cpu
  RAM  = var.vm_memory_mb

  network_adapters {
    network      = var.network
    network_card = "vmxnet3"
  }

  disk_controller_type = ["pvscsi"]

  storage {
    disk_size             = 40960
    disk_thin_provisioned = true
  }

  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_password = var.win_admin_password

  insecure_connection            = true
  set_host_for_datastore_uploads = true
}

---

## Ansible Playbook

- name: Build Windows Template with Packer
  hosts: localhost
  gather_facts: no

  tasks:
    - name: Initialize Packer
      shell: ./packer init ./windows/windows.pkr.hcl

    - name: Run Packer build
      shell: |
        ./packer build \
        -var 'vsphere_user={{ vsphere_user }}' \
        -var 'vsphere_password={{ vsphere_password }}' \
        -var 'vsphere_server={{ vsphere_server }}' \
        -var 'datacenter={{ datacenter }}' \
        -var 'cluster={{ cluster }}' \
        -var 'datastore={{ datastore }}' \
        -var 'network={{ network }}' \
        -var 'template_name={{ template_name }}-gold' \
        -var 'vm_cpu={{ vm_cpu }}' \
        -var 'vm_memory_mb={{ vm_memory_mb }}' \
        -var 'win_admin_password={{ vm_admin_password }}' \
        ./windows/windows.pkr.hcl

---

## Credential Strategy

DO NOT STORE credentials in:
- Packer files
- Ansible files
- Git repo

Use AWX Credentials instead.

---

## AWX Setup

Create credential:
AWX → Resources → Credentials

Attach credential to Job Template.

---

## Workflow

Survey → Packer → Terraform → Ansible

---

## Expected Output

==> Creating VM
==> Uploading ISO
==> Powering on VM
==> Waiting for WinRM

---

## Key Lessons

- Packer runs inside AWX container
- Must include packer binary in repo
- Always run packer init
- Use AWX for credentials

---

## Final State

You now have:
- Secure pipeline
- Reusable gold image
- Automated deployment workflow


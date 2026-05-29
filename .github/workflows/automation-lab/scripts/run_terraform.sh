#!/bin/bash

terraform init

terraform apply -auto-approve \
  -var="vm_name=$VM_NAME" \
  -var="vsphere_server=$VSPHERE_SERVER" \
  -var="vsphere_user=$VSPHERE_USER" \
  -var="vsphere_password=$VSPHERE_PASSWORD"
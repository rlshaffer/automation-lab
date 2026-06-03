- name: Run Terraform
  hosts: localhost
  gather_facts: no

  tasks:
    - name: Initialize Terraform
      command: terraform init
      args:
        chdir: "{{ terraform_dir }}"

    - name: Apply Terraform
      command: >
        terraform apply -auto-approve
      args:
        chdir: "{{ terraform_dir }}"
      environment:
        TF_VAR_vm_name: "{{ vm_name }}"
        TF_VAR_vsphere_server: "{{ vsphere_server }}"
        TF_VAR_vsphere_user: "{{ vsphere_user }}"
        TF_VAR_vsphere_password: "{{ vsphere_password }}"
        TF_VAR_datacenter: "{{ datacenter }}"
        TF_VAR_cluster: "{{ cluster }}"
        TF_VAR_datastore: "{{ datastore }}"
        TF_VAR_network: "{{ network }}"
        TF_VAR_template_name: "{{ template_name }}"

    - name: Get Terraform Outputs
      command: terraform output -json
      args:
        chdir: "{{ terraform_dir }}"
      register: tf_output

    - name: Save outputs as facts
      set_fact:
        terraform_outputs: "{{ tf_output.stdout | from_json }}"
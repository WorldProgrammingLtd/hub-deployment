# hub-deployment
Tools and scripts for deploying the SLC Hub on baremetal

This consists of terraform to make the machines, followed by ansible to configure them.

## Terraform

See [the terraform subdirectory](terraform) for available terraform examples

## Ansible

The ansible can be run against machines provisioned through whatever means you prefer, you don't need to have made them with terraform.

If you make them with provided terraform then terraform will generate a hosts file suitable for ansible to consume.

See [the ansible documentation](ansible/README.md) for more information

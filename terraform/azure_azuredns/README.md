# Terraform files for Azure and Azure DNS

To use this directory you will need to be authenticated to azure via the azure
cli or equivalent.

You need to be logged in and set to the appropriate azure account e.g.

$> az account set --name "My Subscription Name"

And for the default settings you need to accept the terms for the almalinux plan:

$> az vm image terms accept --urn almalinux:almalinux:8-gen2:8.7.2022122801

Read variables.tf and set as appropriate before terraform init, terraform plan
and terraform apply.

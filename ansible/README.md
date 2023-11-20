# Ansible
This folder contains ansible to provision a hub and any number of workers.

You cannot run the worker(s) on the hub node.

Right now this expects an external s3 store and postgresql database.

To use it provide a hosts file and change the settings in the files in vars.

You should have a pre-shared private key to log in to the hosts you're expecting to access or provide access mechanisms through the hosts file.

Licenses: place a hub.txt and a setinit.wps in the license/ folder

Then run all.sh or ansible-playbook main.yaml.

## Hosts example (AWS)

```
[all:vars]
cloud_provider = aws
ingress_url = https://hub.test.wpscloud.co.uk
shared_store_endpoint = 172.17.2.31:/
db_host = test-hub-db.calypti53pcp.eu-west-2.rds.amazonaws.com
db_name = testhub
db_user = hubdb
db_password = shadjg7ad89hjklasdfgbhjkl
s3_endpoint = s3.amazonaws.com
s3_access_key_id = AKIAVSPH6RVLN6J
s3_secret_access_key = RpbPHWt5ucT7PexRy+/X4F5A/Ykf
s3_bucket = test-hubdata
s3_region = eu-west-2

[hub]
1.2.3.4 ansible_user=abc private_name=hubvm.test.wpscloud.co.uk

[workers]
2.3.4.5 ansible_user=abc private_name=worker0.test.wpscloud.co.uk
2.3.4.6 ansible_user=abc private_name=worker1.test.wpscloud.co.uk
```

## Hosts example (Azure)

```
[all:vars]
cloud_provider = azure
ingress_url = https://hub.test.wpscloud.co.uk
shared_store_endpoint = hub-test-store.file.core.windows.net:/hub-test-store/hub-test-shared-store
db_host = hub-test-db.postgres.database.azure.com
db_name = testhub
db_user = hubdb
db_password = sh2djg7ad89hjklasdfgbhjkl
azure_storage_endpoint = https://hub-test.blob.core.windows.net/
azure_storage_account_name = hub-test
azure_storage_access_key = Sx5p8D1iOVcMrhPGCV3iZZI2pB6Or6aSx5p8D1iOVcMrhPGCV3iZZI2pB6Or6a==
azure_storage_container = test-hubdata
azure_storage_region = westeurope

[hub]
1.2.3.4 ansible_user=abc private_name=hubvm.test.wpscloud.co.uk

[workers]
2.3.4.5 ansible_user=abc private_name=worker0.test.wpscloud.co.uk
2.3.4.6 ansible_user=abc private_name=worker1.test.wpscloud.co.uk
```

## Variables

You must set all appropriate variables in vars/common.yaml, either in that file or in hosts as shown above.

vars/ldap.yaml should be setup if you'd like ldap integration.

vars/license.yaml you must set the license type either a1 (for altair units) or
alm (for license manager). See vars/license.yaml for more details.

# Local Postgres Install

This is optional. This currently only supports install using local .RPM files. To use this define your database variables in /vars/common.yaml:

db_host, db_name, db_user, db_password, db_ssl_mode

Define a host for postgresql in your hosts file:

[postgresql]
10.100.10.10 ansible_user=ansible_user private_name=host-postgres

This was created to work with SQL Server 13 but may work with other versions. Navigate to following link:

https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-8-x86_64/

Download the following files:

postgresql13-libs-X.Y-1PGDG.rhel8.x86_64.rpm
postgresql13-X.Y-1PGDG.rhel8.x86_64.rpm
postgresql13-server-X.Y-1PGDG.rhel8.x86_64.rpm

Copy these files to /rpms

Make sure that the files referenced in postgres_install.yaml match the files that you have uploaded

# Local SeaweedFS Install

This is optional. This currently only supports install using local binary file. To use this define your database variables in /vars/common.yaml:

s3_use_iam, s3_insecure, s3_endpoint, s3_access_key_id, secret_access_key, s3_bucket, s3_region

Define a host for seaweedfs in your hosts file:

[seaweedfs]
10.100.10.10 ansible_user=ansible_user private_name=host-seaweedfs

This was created to work with the "linux_amd64.tar.gz" from the following link:

https://github.com/chrislusf/seaweedfs/releases

Copy this file to /rpms on the ansible host

Make sure that the file referenced in seaweedfs_install.yaml matches the file that you have uploaded.







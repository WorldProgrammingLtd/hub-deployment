[all:vars]
ingress_url = ${ingress_url}
shared_store_endpoint = ${shared_store_ip}:/
db_host = ${db_host}
db_name = ${db_name}
db_user = ${db_user}
db_password = ${db_password}
db_ssl_mode = require
s3_use_iam = ${s3_use_iam}
s3_endpoint = ${s3_endpoint}
s3_access_key_id = ${s3_access_key_id}
s3_secret_access_key = ${s3_secret_access_key}
s3_bucket = ${s3_bucket}
s3_region = ${s3_region}
s3_insecure = false

[hub]
${hub_ip} ansible_user=${username} private_name=${hub_private_name}

[workers]
%{ for worker in workers ~}
${worker.public_ip} ansible_user=${username} private_name=${worker.private_name}
%{endfor ~}

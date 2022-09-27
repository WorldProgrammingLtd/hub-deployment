[all:vars]
ingress_url = ${ingress_url}
shared_store_ip = ${shared_store_ip}
db_host = ${db_host}
db_name = ${db_name}
db_user = ${db_user}
db_password = ${db_password}
db_sslMode = require
s3_useIam = ${s3_useIam}
s3_endpoint = ${s3_endpoint}
s3_accessKeyId = ${s3_accessKeyId}
s3_secretAccessKey = ${s3_secretAccessKey}
s3_bucket = ${s3_bucket}
s3_region = ${s3_region}
s3_insecure = false

[hub]
${hub_ip} ansible_user=${username} private_name=${hub_private_name}

[workers]
%{ for worker in workers ~}
${worker.public_ip} ansible_user=${username} private_name=${worker.private_name}
%{endfor ~}

# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0 https://aws.amazon.com/apache-2-0/

region = "eu-west-1"
dynamodb_port = 8000
local_services_port = 8001
redis_port = 6379
dynamodb_endpoint_url = "http://dynamodb"
sqs_endpoint_url = "http://local-services"
redis_endpoint_url = "localhost"
local_service_endpoint_url = "http://local-services"
aws_htc_ecr = "125796369274.dkr.ecr.eu-west-1.amazonaws.com"
k8s_config_context = "default"
k8s_config_path = "/etc/rancher/k3s/k3s.yaml"
redis_with_ssl = false
connection_redis_timeout = 5000
certificates_dir_path = "/home/sysadmin/Armonik/aws-htc-grid/redis_certificates"
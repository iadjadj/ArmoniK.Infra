variable "docker_registry" {
  description = "URL of Amazon ECR image repostiories"
}

variable "lambda_runtime" {
  description = "Python version"
}

variable "lambda_timeout" {
  description = "Lambda function timeout"
}

variable "ddb_status_table" {
  description = "DBtable name"
}

variable "queue_name" {
  description = "Armonik queue name"
}

variable "dlq_name" {
  description = "Armonik queue dlq name"
}

variable "grid_storage_service" {
  description = "Configuration string for internal results storage system"
}

variable "grid_queue_service" {
  description = "Configuration string for the type of queuing service to be used"
}

variable "grid_queue_config" {
  default = "{'sample':15}"
  description = "dictionary queue config"
}

variable "tasks_status_table_config" {
  default = "{'sample':15}"
  description = "Custom configuration for status table"
}

variable "task_input_passed_via_external_storage" {
  description = "Indicator for passing the args through stdin"
}

variable "lambda_name_ttl_checker" {
  description = "Lambda name for ttl checker"
}

variable "lambda_name_submit_tasks" {
  description = "Lambda name for submit task"
}

variable "lambda_name_cancel_tasks" {
  description = "Lambda name for cancel tasks"
}

variable "lambda_name_get_results" {
  description = "Lambda name for get result task"
}

variable "metrics_are_enabled" {
  description = "If set to True(1) then metrics will be accumulated and delivered downstream for visualisation"
}

variable "metrics_submit_tasks_lambda_connection_string" {
  description = "The type and the connection string for the downstream"
}

variable "metrics_get_results_lambda_connection_string" {
  description = "The type and the connection string for the downstream"
}

variable "metrics_cancel_tasks_lambda_connection_string" {
  description = "The type and the connection string for the downstream"
}

variable "metrics_ttl_checker_lambda_connection_string" {
  description = "The type and the connection string for the downstream"
}

variable "agent_use_congestion_control" {
  description = "Use Congestion Control protocol at pods to avoid overloading DDB"
}

variable "suffix" {
  description = "suffix for generating unique name for AWS resource"
}

variable "nlb_influxdb" {
  description = "network load balancer url  in front of influxdb"
  default = ""
}

variable "cluster_name" {
  description = "ARN of the user pool used for authentication"
}

variable "tasks_status_table_service" {
  description = "Status table sertvice"
}

variable "mongodb_port" {
  description = "mongodb port"
}

variable "tasks_queue_name" {
  description = "HTC queue name"
}

variable "redis_port" {
  description = "Port for Redis instance"
}

variable "queue_port" {
  description = "Port for queue instance"
}

variable "redis_with_ssl" {
  type = bool
  description = "redis with ssl"
}

variable "connection_redis_timeout" {
  description = "connection redis timeout"
}

variable "certificates_dir_path" {
  description = "Path of the directory containing the certificates redis.crt, redis.key, ca.crt"
}

variable "redis_ca_cert" {
  description = "path to the authority certificate file (ca.crt) of the redis server in the docker machine"
}

variable "redis_key_file" {
  description = "path to the authority certificate file (redis.key) of the redis server in the docker machine"
}

variable "redis_cert_file" {
  description = "path to the client certificate file (redis.crt) of the redis server in the docker machine"
}

variable "cancel_tasks_port" {
  description = "Port for Cancel Tasks Lambda function"
}

variable "submit_task_port" {
  description = "Port for Submit Task Lambda function"
}

variable "get_results_port" {
  description = "Port for Get Results Lambda function"
}

variable "ttl_checker_port" {
  description = "Port for TTL Checker Lambda function"
}

variable "nginx_port" {
  description = "Port for nginx instance"
}

variable "nginx_ssl_port" {
  description = "Port SSL for nginx instance"
}

variable "nginx_endpoint_url" {
  description = "Url for nginx instance"
}

variable "kubectl_path_documents" {
  description = "path to manifest documents"
}

variable "image_pull_policy" {
  description = "Pull image policy"
}

variable "api_gateway_service" {
  description = "API Gateway Service"
}

variable "redis_secrets" {
  description = "Kubernetes secret for Redis certificates"
}

variable "nginx_ingress_name" {
  description = "The name of this nginx ingress controller"
  type        = string
  default     = "ingress-nginx"
}
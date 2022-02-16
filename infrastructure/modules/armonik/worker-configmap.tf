# configmap with all the variables
resource "kubernetes_config_map" "worker_config" {
  metadata {
    name      = "worker-configmap"
    namespace = var.namespace
  }
  data = {
    target_grpc_sockets_path   = "/cache"
    target_data_path           = "/data"
    Serilog__MinimumLevel      = var.logging_level
    Grpc__Endpoint             = local.control_plane_url
    S3Storage__ServiceURL      = (var.storage_endpoint_url.shared.service_url != null && var.storage_endpoint_url.shared.service_url != "" ?  var.storage_endpoint_url.shared.service_url : "")
    S3Storage__AccessKeyId     = (var.storage_endpoint_url.shared.access_key_id != null && var.storage_endpoint_url.shared.access_key_id != "" ? var.storage_endpoint_url.shared.access_key_id : "")
    S3Storage__SecretAccessKey = (var.storage_endpoint_url.shared.secret_access_key != null && var.storage_endpoint_url.shared.secret_access_key != "" ? var.storage_endpoint_url.shared.secret_access_key : "")
    S3Storage__BucketName      = (var.storage_endpoint_url.shared.name != null && var.storage_endpoint_url.shared.name != "" ? var.storage_endpoint_url.shared.name : "")
    FileStorageType            = local.file_storage_type
  }
}

# Storage
output "storage_endpoint_url" {
  description = "Storage endpoints URLs"
  value       = {
    activemq = {
      url                    = module.mq.activemq_endpoint_url.url
      host                   = module.mq.activemq_endpoint_url.host
      port                   = module.mq.activemq_endpoint_url.port
      web_url                = module.mq.web_url
      web_host               = split(":", split("/", module.mq.web_url)[2])[0]
      web_port               = split(":", split("/", module.mq.web_url)[2])[1]
      allow_host_mismatch    = false
      borker_name            = module.mq.mq_name
      trigger_authentication = module.mq.trigger_authentication
      aws_region             = module.mq.aws_region
      credentials            = {
        secret       = module.mq.user_credentials.secret
        username_key = module.mq.user_credentials.username_key
        password_key = module.mq.user_credentials.password_key
      }
      certificates           = {
        secret      = ""
        ca_filename = ""
      }
    }
    redis    = {
      url          = module.elasticache.redis_endpoint_url.url
      host         = module.elasticache.redis_endpoint_url.host
      port         = module.elasticache.redis_endpoint_url.port
      timeout      = 3000
      ssl_host     = ""
      credentials  = {
        secret       = ""
        username_key = ""
        password_key = ""
      }
      certificates = {
        secret      = ""
        ca_filename = ""
      }
    }
    mongodb  = {
      url                = module.mongodb.url
      host               = module.mongodb.host
      port               = module.mongodb.port
      allow_insecure_tls = true
      credentials        = {
        secret       = module.mongodb.user_credentials.secret
        username_key = module.mongodb.user_credentials.username_key
        password_key = module.mongodb.user_credentials.password_key
      }
      certificates       = {
        secret      = module.mongodb.user_certificate.secret
        ca_filename = module.mongodb.user_certificate.ca_filename
      }
    }
    shared   = {
      service_url       = "https://s3.${var.region}.amazonaws.com"
      kms_key_id        = module.s3_fs.kms_key_id
      name              = module.s3_fs.s3_bucket_name
      access_key_id     = ""
      secret_access_key = ""
      file_storage_type = "S3"
    }
  }
}

module "s3_bucket" {
  source                                = "terraform-aws-modules/s3-bucket/aws"
  version                               = "2.13.0"
  bucket                                = var.name
  acl                                   = "private"
  force_destroy                         = true
  versioning                            = {
    enabled = true
  }
  tags                                  = local.tags
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
  server_side_encryption_configuration  = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.kms_key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
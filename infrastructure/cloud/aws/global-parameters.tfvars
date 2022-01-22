# one these:
# profile="default"
# profile="cacib-gmdprs-sbox/SysAdmin"
# profile="cacib-cloud-equity-dev/SysAdmin"
# profile="cacib-gmdprs-dev/DevOPS"
profile = "default"

# Region
region = "eu-west-3"

# TAG
tag = "main"

# KMS
kms_parameters = {
  name                     = "armonik-kms"
  multi_region             = false
  deletion_window_in_days  = 7
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  key_usage                = "ENCRYPT_DECRYPT"
  enable_key_rotation      = true
  is_enabled               = true
}

# ARN of encrypt/decrypt keys
encryption_keys_arn = {
  vpc_flow_log_cloudwatch_log_group = ""
  eks                               = {
    secrets              = ""
    ebs                  = ""
    cloudwatch_log_group = ""
  }
}

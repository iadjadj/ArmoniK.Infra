variable "ebs" {
  description = "AWS EBS for shared storage between pods"
  type        = object({
    region            = string
    profile           = string
    availability_zone = string
    size              = number
    encrypted         = bool
    kms_key_id        = string
    tags              = object({})
  })
}
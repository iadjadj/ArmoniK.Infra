# AWS KMS
module "kms" {
  source = "../../modules/aws/kms"
  name   = "armonik-kms-${local.tag}"
  tags   = local.tags
}

# AWS ECR
module "ecr" {
  source       = "../../modules/aws/ecr"
  tags         = local.tags
  kms_key_id   = (var.ecr.kms_key_id != "" ? var.ecr.kms_key_id : module.kms.selected.arn)
  repositories = var.ecr.repositories
}

# AWS VPC
module "vpc" {
  source = "../../modules/aws/vpc"
  tags   = local.tags
  name   = "${var.vpc.name}-${local.tag}"
  vpc    = {
    cluster_name                                    = local.cluster_name
    private_subnets                                 = var.vpc.cidr_block_private
    public_subnets                                  = var.vpc.cidr_block_public
    main_cidr_block                                 = var.vpc.main_cidr_block
    pod_cidr_block_private                          = var.vpc.pod_cidr_block_private
    enable_private_subnet                           = var.vpc.enable_private_subnet
    enable_nat_gateway                              = var.vpc.enable_private_subnet
    single_nat_gateway                              = var.vpc.enable_private_subnet
    flow_log_cloudwatch_log_group_retention_in_days = var.vpc.flow_log_cloudwatch_log_group_retention_in_days
    flow_log_cloudwatch_log_group_kms_key_id        = (var.vpc.flow_log_cloudwatch_log_group_kms_key_id != "" ? var.vpc.flow_log_cloudwatch_log_group_kms_key_id : module.kms.selected.arn)
  }
}

# AWS S3 as shared storage
module "s3_bucket_fs" {
  source     = "../../modules/aws/s3"
  tags       = local.tags
  name       = "${var.s3_bucket_fs.name}-${local.tag}"
  kms_key_id = (var.s3_bucket_fs.kms_key_id != "" ? var.s3_bucket_fs.kms_key_id : module.kms.selected.arn)
}

# AWS Elasticache
module "elasticache" {
  source      = "../../modules/aws/elasticache"
  tags        = local.tags
  name        = "${var.elasticache.name}-${local.tag}"
  elasticache = {
    engine           = var.elasticache.engine
    engine_version   = var.elasticache.engine_version
    node_type        = var.elasticache.node_type
    kms_key_id       = (var.elasticache.kms_key_id != "" ? var.elasticache.kms_key_id : module.kms.selected.arn)
    vpc              = {
      id          = module.vpc.id
      cidr_blocks = concat([module.vpc.cidr_block], module.vpc.pod_cidr_block_private)
      subnet_ids  = module.vpc.private_subnet_ids
    }
    cluster_mode     = {
      replicas_per_node_group = var.elasticache.cluster_mode.replicas_per_node_group
      num_node_groups         = var.elasticache.cluster_mode.num_node_groups
    }
    multi_az_enabled = var.elasticache.multi_az_enabled
  }
  depends_on  = [module.vpc]
}

# AWS EKS
module "eks" {
  source            = "../../modules/aws/eks"
  tags              = local.tags
  name              = local.cluster_name
  eks               = {
    region                               = var.region
    cluster_version                      = var.eks.cluster_version
    vpc_private_subnet_ids               = module.vpc.private_subnet_ids
    vpc_id                               = module.vpc.id
    pods_subnet_ids                      = module.vpc.pods_subnet_ids
    enable_private_subnet                = var.vpc.enable_private_subnet
    cluster_endpoint_public_access       = var.eks.cluster_endpoint_public_access
    cluster_endpoint_public_access_cidrs = var.eks.cluster_endpoint_public_access_cidrs
    cluster_log_retention_in_days        = var.eks.cluster_log_retention_in_days
    docker_images                        = {
      cluster_autoscaler = {
        image = var.eks.docker_images.cluster_autoscaler.image
        tag   = var.eks.docker_images.cluster_autoscaler.tag
      }
      instance_refresh   = {
        image = var.eks.docker_images.instance_refresh.image
        tag   = var.eks.docker_images.instance_refresh.tag
      }
    }
    encryption_keys                      = {
      cluster_log_kms_key_id    = (var.eks.encryption_keys.cluster_log_kms_key_id != "" ? var.eks.encryption_keys.cluster_log_kms_key_id : module.kms.selected.arn)
      cluster_encryption_config = (var.eks.encryption_keys.cluster_encryption_config != "" ? var.eks.encryption_keys.cluster_encryption_config : module.kms.selected.arn)
      ebs_kms_key_id            = (var.eks.encryption_keys.ebs_kms_key_id != "" ? var.eks.encryption_keys.ebs_kms_key_id : module.kms.selected.arn)
    }
    s3_fs                                = {
      name       = module.s3_bucket_fs.s3_bucket_name
      kms_key_id = module.s3_bucket_fs.kms_key_id
      host_path  = var.eks.s3_fs.host_path
    }
  }
  eks_worker_groups = var.eks_worker_groups
  depends_on        = [
    module.vpc,
    module.s3_bucket_fs
  ]
}
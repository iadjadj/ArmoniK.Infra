# Storage
module "storage" {
  source    = "./storage"
  namespace = var.namespace

  # Object storage : Redis
  object_storage = {
    replicas = var.object_storage.replicas
    port     = var.object_storage.port
    secret   = var.object_storage.secret
  }

  # Table storage : MongoDB
  table_storage = {
    replicas = var.table_storage.replicas
    port     = var.table_storage.port
  }

  # Queue storage : ActiveMQ
  queue_storage = {
    replicas = var.queue_storage.replicas
    port     = var.queue_storage.port
    secret   = var.queue_storage.secret
  }

  # Shared storage (like NFS)
  shared_storage = {
    storage_class           = {
      name                   = var.shared_storage.storage_class.name
      provisioner            = var.shared_storage.storage_class.provisioner
      volume_binding_mode    = var.shared_storage.storage_class.volume_binding_mode
      allow_volume_expansion = var.shared_storage.storage_class.allow_volume_expansion
    }
    persistent_volume       = {
      name                             = var.shared_storage.persistent_volume.name
      persistent_volume_reclaim_policy = var.shared_storage.persistent_volume.persistent_volume_reclaim_policy
      access_modes                     = var.shared_storage.persistent_volume.access_modes
      size                             = var.shared_storage.persistent_volume.size
      host_path                        = var.shared_storage.persistent_volume.host_path
    }
    persistent_volume_claim = {
      name         = var.shared_storage.persistent_volume_claim.name
      access_modes = var.shared_storage.persistent_volume_claim.access_modes
      size         = var.shared_storage.persistent_volume_claim.size
    }
  }
}

# ArmoniK components
module "armonik" {
  source     = "./armonik"
  namespace  = var.namespace
  depends_on = [module.storage]

  armonik = {
    control_plane    = {
      replicas          = var.armonik.control_plane.replicas
      image             = var.armonik.control_plane.tag != "" ? "${var.armonik.control_plane.image}:${var.armonik.control_plane.tag}" : var.armonik.control_plane.image
      image_pull_policy = var.armonik.control_plane.image_pull_policy
      port              = var.armonik.control_plane.port
    }
    compute_plane    = {
      replicas      = var.armonik.compute_plane.replicas
      polling_agent = {
        image                 = var.armonik.compute_plane.polling_agent.tag != "" ? "${var.armonik.compute_plane.polling_agent.image}:${var.armonik.compute_plane.polling_agent.tag}" : var.armonik.compute_plane.polling_agent.image
        image_pull_policy     = var.armonik.compute_plane.polling_agent.image_pull_policy
        limits                = {
          cpu    = var.armonik.compute_plane.polling_agent.limits.cpu
          memory = var.armonik.compute_plane.polling_agent.limits.memory
        }
        requests              = {
          cpu    = var.armonik.compute_plane.polling_agent.requests.cpu
          memory = var.armonik.compute_plane.polling_agent.requests.memory
        }
        object_storage_secret = var.object_storage.secret
      }
      compute       = {
        image             = var.armonik.compute_plane.compute.tag != "" ? "${var.armonik.compute_plane.compute.image}:${var.armonik.compute_plane.compute.tag}" : var.armonik.compute_plane.compute.image
        image_pull_policy = var.armonik.compute_plane.compute.image_pull_policy
        limits            = {
          cpu    = var.armonik.compute_plane.compute.limits.cpu
          memory = var.armonik.compute_plane.compute.limits.memory
        }
        requests          = {
          cpu    = var.armonik.compute_plane.compute.requests.cpu
          memory = var.armonik.compute_plane.compute.requests.memory
        }
      }
    }
    storage_services = {
      object_storage         = {
        type = var.armonik.storage_services.object_storage.type
        url  = module.storage.table_storage.spec.0.cluster_ip
        port = module.storage.table_storage.spec.0.port.0.port
      }
      table_storage          = {
        type = var.armonik.storage_services.table_storage.type
        url  = module.storage.table_storage.spec.0.cluster_ip
        port = module.storage.table_storage.spec.0.port.0.port
      }
      queue_storage          = {
        type = var.armonik.storage_services.queue_storage.type
        url  = module.storage.table_storage.spec.0.cluster_ip
        port = module.storage.table_storage.spec.0.port.0.port
      }
      lease_provider_storage = {
        type = var.armonik.storage_services.lease_provider_storage.type
        url  = module.storage.table_storage.spec.0.cluster_ip
        port = module.storage.table_storage.spec.0.port.0.port
      }
      shared_storage         = {
        claim_name  = module.storage.shared_storage_persistent_volume_claim.metadata.0.name
        target_path = var.armonik.storage_services.shared_storage.target_path
      }
    }
  }
}
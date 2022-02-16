# Kubernetes Redis deployment
resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis"
    namespace = var.namespace
    labels    = {
      app     = "storage"
      type    = "object"
      service = "redis"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = "storage"
        type    = "object"
        service = "redis"
      }
    }
    template {
      metadata {
        name   = "redis"
        labels = {
          app     = "storage"
          type    = "object"
          service = "redis"
        }
      }
      spec {
        node_selector = var.redis.node_selector
        toleration {
          key      = keys(var.redis.node_selector)[0]
          operator = "Equal"
          value    = values(var.redis.node_selector)[0]
          effect   = "NoSchedule"
        }
        container {
          name    = "redis"
          image   = "${var.redis.image}:${var.redis.tag}"
          command = ["redis-server"]
          args    = [
            "--tls-port 6379",
            "--port 0",
            "--tls-cert-file /certificates/cert.pem",
            "--tls-key-file /certificates/key.pem",
            "--tls-auth-clients no",
            "--requirepass ${random_password.redis_password.result}"
          ]
          port {
            container_port = 6379
          }
          volume_mount {
            name       = "redis-storage-secret-volume"
            mount_path = "/certificates"
            read_only  = true
          }
        }
        volume {
          name = "redis-storage-secret-volume"
          secret {
            secret_name = kubernetes_secret.redis_certificate.metadata[0].name
            optional    = false
          }
        }
      }
    }
  }
}

# Kubernetes Redis service
resource "kubernetes_service" "redis" {
  metadata {
    name      = kubernetes_deployment.redis.metadata.0.name
    namespace = kubernetes_deployment.redis.metadata.0.namespace
    labels    = {
      app     = kubernetes_deployment.redis.metadata.0.labels.app
      type    = kubernetes_deployment.redis.metadata.0.labels.type
      service = kubernetes_deployment.redis.metadata.0.labels.service
    }
  }
  spec {
    type     = "ClusterIP"
    selector = {
      app     = kubernetes_deployment.redis.metadata.0.labels.app
      type    = kubernetes_deployment.redis.metadata.0.labels.type
      service = kubernetes_deployment.redis.metadata.0.labels.service
    }
    port {
      name        = kubernetes_deployment.redis.metadata.0.name
      port        = 6379
      target_port = 6379
      protocol    = "TCP"
    }
  }
}
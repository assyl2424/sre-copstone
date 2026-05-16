terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Deployment for the Orders Service
resource "kubernetes_deployment" "orders_service" {
  metadata {
    name      = "orders-service"
    namespace = kubernetes_namespace.production.metadata[0].name
    labels = {
      app = "orders-service"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "orders-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "orders-service"
        }
      }

      spec {
        container {
          image = "ghcr.io/your-user/sre-orders-service:latest" # Placeholder, user should update
          name  = "orders-service"

          port {
            container_port = 8000
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

# Service for the Orders Service
resource "kubernetes_service" "orders_service" {
  metadata {
    name      = "orders-service"
    namespace = kubernetes_namespace.production.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.orders_service.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8000
    }
    type = "ClusterIP"
  }
}

# Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler_v2" "orders_hpa" {
  metadata {
    name      = "orders-hpa"
    namespace = kubernetes_namespace.production.metadata[0].name
  }

  spec {
    max_replicas = 10
    min_replicas = 2

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.orders_service.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type               = "Utilization"
          average_utilization = 50
        }
      }
    }
  }
}

variable "image_tag" {
  description = "Docker image tag for orders-service"
  type        = string
  default     = "latest"
}

variable "namespace_prod" {
  description = "Production namespace"
  type        = string
  default     = "production"
}

variable "namespace_monitoring" {
  description = "Monitoring namespace"
  type        = string
  default     = "monitoring"
}

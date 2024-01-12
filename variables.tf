variable "sks_security_group" {
  description = "SKS security group"
  type        = string
  default     = null
}
variable "sks_node_pools" {
  description = "List of node pool configurations"
  nullable    = false
  type = list(object({
    name                 = string
    instance_type        = string
    size                 = number
    disk_size            = number
    anti_affinity_groups = list(string)
    labels               = map(string)
  }))
  default = [
    {
      name                 = "default"
      instance_type        = "standard.extra-large"
      size                 = 3
      disk_size            = 100
      anti_affinity_groups = []
      labels               = {}
    }
  ]
}

variable "sks_zone" {
  description = "SKS Zone"
  type        = string
  default     = "de-fra-1"
}

variable "sks_description" {
  description = "SKS control plane description"
  type        = string
}

variable "sks_version" {
  description = "SKS control plane K8s version"
  type        = string
}

variable "sks_auto_upgrade" {
  description = "Enable automatic upgrading of the control plane version."
  type        = bool
  default     = true
}

variable "sks_exoscale_ccm" {
  description = "Deploy the Exoscale Cloud Controller Manager in the control plane (may only be set at creation time)."
  type        = bool
  default     = true
}

variable "sks_metrics_server" {
  description = "Deploy the Kubernetes Metrics Server in the control plane (may only be set at creation time)."
  type        = bool
  default     = true
}

variable "sks_service_level" {
  description = "The service level of the control plane (pro or starter; may only be set at creation time)."
  type        = string
  default     = "starter"
}

variable "sks_cni" {
  description = "Network plugin (may only be set at creation time)."
  type        = string
  default     = "cilium"
}

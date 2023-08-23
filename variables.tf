variable "sks_security_group" {
  description = "SKS security group"
  type        = string
  default     = null
}

variable "sks_worker_disk_size" {
  description = "SKS worker disk size"
  type        = number
  default     = 100
}
variable "sks_nodepool_size" {
  description = "SKS nodepool size"
  type        = number
  default     = 4
}

variable "sks_worker_instance_type" {
  description = "SKS worker instance type"
  type        = string
  default     = "standard.extra-large"
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

variable "worker_anti_affinity_groups" {
  description = "Anti Affinity groups for worker node pool"
  type        = set(string)
  default     = []
}

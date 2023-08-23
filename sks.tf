#
# Docs for the SKS provider: https://registry.terraform.io/providers/exoscale/exoscale/latest/docs
#

resource "exoscale_sks_cluster" "sks_cluster" {
  zone           = var.sks_zone
  name           = terraform.workspace
  description    = var.sks_description
  auto_upgrade   = var.sks_auto_upgrade
  exoscale_ccm   = var.sks_exoscale_ccm
  metrics_server = var.sks_metrics_server
  service_level  = var.sks_service_level
  version        = var.sks_version
  cni            = var.sks_cni
}

resource "exoscale_anti_affinity_group" "sks_anti_affinity_group" {
  for_each = toset(var.worker_anti_affinity_groups)
  name     = each.value
}

resource "exoscale_sks_nodepool" "workers" {
  zone                    = var.sks_zone
  cluster_id              = exoscale_sks_cluster.sks_cluster.id
  name                    = "worker"
  instance_type           = var.sks_worker_instance_type
  instance_prefix         = "worker"
  size                    = var.sks_nodepool_size
  disk_size               = var.sks_worker_disk_size
  security_group_ids      = [exoscale_security_group.sks.id]
  anti_affinity_group_ids = [for group in exoscale_anti_affinity_group.sks_anti_affinity_group : group.id]

  labels = {
    "cloud.fusedeck/nodetype" = "worker"
  }
}

resource "exoscale_sks_kubeconfig" "sks_cluster_admin" {
  zone       = var.sks_zone
  cluster_id = exoscale_sks_cluster.sks_cluster.id
  user       = "kubernetes-admin"
  groups     = ["system:masters"]
}

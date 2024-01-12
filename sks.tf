#
# Docs for the SKS provider: https://registry.terraform.io/providers/exoscale/exoscale/latest/docs
#
locals {
  all_anti_affinity_groups = distinct(flatten([for np in var.sks_node_pools : np.anti_affinity_groups]))
}
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
  for_each = toset(local.all_anti_affinity_groups)
  name     = each.value
}

resource "exoscale_sks_nodepool" "workers" {
  for_each = { for np in var.sks_node_pools : np.name => np }

  zone                    = var.sks_zone
  cluster_id              = exoscale_sks_cluster.sks_cluster.id
  name                    = each.value.name
  instance_type           = each.value.instance_type
  instance_prefix         = "worker-${each.value.name}"
  size                    = each.value.size
  disk_size               = each.value.disk_size
  security_group_ids      = [exoscale_security_group.sks.id]
  anti_affinity_group_ids = [for group in each.value.anti_affinity_groups : exoscale_anti_affinity_group.sks_anti_affinity_group[group].id]
  labels                  = merge({ "role" = "worker" }, each.value.labels)
}


resource "exoscale_sks_kubeconfig" "sks_cluster_admin" {
  zone       = var.sks_zone
  cluster_id = exoscale_sks_cluster.sks_cluster.id
  user       = "kubernetes-admin"
  groups     = ["system:masters"]
}

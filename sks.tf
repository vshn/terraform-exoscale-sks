#
# Docs for the SKS provider: https://registry.terraform.io/providers/exoscale/exoscale/latest/docs
#
resource "exoscale_security_group" "sks" {
  name = coalesce(var.sks_security_group, var.sks_name)
}

resource "exoscale_security_group_rule" "sks" {
  for_each = {
    kubelet_logs_ipv4      = { protocol = "TCP", port = 10250, sg = exoscale_security_group.sks.id }
    kubelet_nodeports_ipv4 = { protocol = "TCP", port = "30000-32767", cidr = "0.0.0.0/0" }
    kubelet_nodeports_ipv6 = { protocol = "TCP", port = "30000-32767", cidr = "::/0" }
    node_metrics_ipv4      = { protocol = "TCP", port = 9100, sg = exoscale_security_group.sks.id }
    # Required for cilium https://community.exoscale.com/documentation/sks/quick-start/
    icmp_ping             = { description = "ICMP", protocol = "ICMP", icmp_type = 8, icmp_code = 0, sg = exoscale_security_group.sks.id }
    cilium_vxlan_sg       = { description = "cilium VXLAN overlay", protocol = "UDP", port = 8472, sg = exoscale_security_group.sks.id }
    cilium_healthcheck_sg = { description = "cilium health check", protocol = "TCP", port = 4240, sg = exoscale_security_group.sks.id }
    nlb_healthcheck       = { description = "nlb tcp health check", protocol = "TCP", port = "30000-32767", psg = "public-nlb-healthcheck-sources" }
  }

  security_group_id      = exoscale_security_group.sks.id
  protocol               = each.value.protocol
  type                   = "INGRESS"
  icmp_type              = try(each.value.icmp_type, null)
  icmp_code              = try(each.value.icmp_code, null)
  start_port             = try(split("-", each.value.port)[0], each.value.port, null)
  end_port               = try(split("-", each.value.port)[1], each.value.port, null)
  user_security_group_id = try(each.value.sg, null)
  public_security_group  = try(each.value.psg, null)
  cidr                   = try(each.value.cidr, null)
}

resource "exoscale_sks_cluster" "sks_cluster" {
  zone           = var.sks_zone
  name           = var.sks_name
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

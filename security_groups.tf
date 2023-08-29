resource "exoscale_security_group" "sks" {
  name = coalesce(var.sks_security_group, terraform.workspace)
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
    calico_vxlan_sg       = { description = "calico VXLAN", protocol = "UDP", port = 4789, sg = exoscale_security_group.sks.id }
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

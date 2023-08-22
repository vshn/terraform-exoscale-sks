output "kubeconfig" {
  value     = exoscale_sks_kubeconfig.sks_cluster_admin.kubeconfig
  sensitive = true
}
